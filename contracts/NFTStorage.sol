pragma solidity ^0.6.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/IRandoms.sol";
import "./weapons.sol";
import "./characters.sol";

contract NFTStorage is IERC721ReceiverUpgradeable, Initializable, AccessControlUpgradeable
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes32 public constant GAME_ADMIN = keccak256("GAME_ADMIN");

    Weapons weapons;
    Characters characters;
    IRandoms public randoms;

    // sender + token address => ids
    mapping(address => mapping(address => EnumerableSet.UintSet)) private storedItems;
    // token address + id => owner who stored
    mapping(address => mapping(uint256 => address)) private storedItemsOwners;
    // All stored items
    mapping(address => EnumerableSet.UintSet) private allStoredItems;

    // Keeping thing in check
    // A player can only have one pending request at a time

    uint8 public constant BRIDGE_STATUS_NONE = 0;
    uint8 public constant BRIDGE_STATUS_PENDING = 1;
    uint8 public constant BRIDGE_STATUS_PROCESSING = 2;
    uint8 public constant BRIDGE_STATUS_DONE = 3;
    uint8 public constant BRIDGE_STATUS_ERROR = 4;

    struct BridgeTransfer {
        address owner;
        address nftAddress;

        uint256 requestBlock; // For tracking. Requested on block x
        uint256 lastUpdateBlock; // For tracking. Last Update on block y
        uint256 nftId;

        uint8 chainId; // uint 8 should be enough
        uint8 status; // enumeration. 0 => nothing, 1 => transfer requested, 2 => moved   
    }

    // Bot stuff
    uint256 private _bridgeTransfersAt;
    uint256 private _bridgeTransfers;
    mapping(uint8 => bool) private _bridgeEnabled; // Which chain can we go to from here?
    bool private _botEnabled;
    mapping(uint256 => BridgeTransfer) private bridgeTransfers;

    // Player stuff
    // Player => bridgeTransferId
    mapping(address => uint256) private bridgeTransfersOfPlayers;

    // NFT stuff, an NFT should at most have one BridgeTransfer
    // NFT => id => bridgeTransferId
    mapping(address => mapping(uint256 => uint256)) private bridgeTransfersOfNFTs;

    // address is IERC721
    EnumerableSet.AddressSet private supportedTokenTypes; 

    uint8 public constant BRIDGED_STATUS_AVAILABLE = 1;
    uint8 public constant BRIDGED_STATUS_WITHDRAWN = 2;

    // Bot deposited items to be extracted by player
    uint8 public constant NFT_TYPE_WEAPON = 1;
    uint8 public constant NFT_TYPE_CHARACTER = 2;

    mapping(uint8 => address) private nftTypeToAddress;

    // Struct to hold data that will always be needed + rename because it can't be packed.
    // bridgedTransfersMeta will hold actual NFT data packed
    struct BridgedTransfer {
        address owner;

        uint8 nftType;
        uint8 sourceChain;
        uint256 sourceId;
        
        string rename;

        uint256 arrivedAt; // For tracking. Arrived on block x
        uint256 lastUpdateBlock; // For tracking. Last Update on block y

        uint8 status; // enumeration. 0 => waiting, 1 => claimed 
    }
    
    // Player address => items to be extracted
    mapping(address => EnumerableSet.UintSet) private receivedNFTs;

    uint256 private _bridgedTransfersAt;
    mapping(uint256 => BridgedTransfer) private bridgedTransfers;
    mapping(uint256 => uint256) private bridgedTransfersMeta;

    event NFTStored(address indexed owner, IERC721 indexed nftAddress, uint256 indexed nftID);
    event NFTWithdrawn(address indexed owner, IERC721 indexed nftAddress, uint256 indexed nftID);
    event NFTBridgeRequest(address indexed owner, IERC721 indexed nftAddress, uint256 indexed nftID);
    event NFTBridgeCancel(address indexed owner);
    event NFTBridgeUpdate(uint256 indexed requestId, uint8 status, bool forced);
    event TransferIn(address indexed receiver, uint8 nftType, uint8 sourceChain, uint256 indexed sourceId);
    event NFTBridgedOut(address indexed receiver, uint256 indexed bridgedId, uint8 nftType, uint256 indexed mintedId);

    function initialize(address _weaponsAddress, address _charactersAddress/*, IRandoms _randoms*/)
        public
        initializer
    {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        weapons = Weapons(_weaponsAddress);
        nftTypeToAddress[NFT_TYPE_WEAPON] = _weaponsAddress;

        characters = Characters(_charactersAddress);
        nftTypeToAddress[NFT_TYPE_CHARACTER] =_charactersAddress;
        //randoms = _randoms;
    }


    modifier restricted() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "AO");
        _;
    }

    modifier gameAdminRestricted() {
        require(hasRole(GAME_ADMIN, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "NGA");
        _;
    }

    modifier isStored(IERC721 _tokenAddress, uint256 id) {
        require(
            supportedTokenTypes.contains(address(_tokenAddress)) &&
                storedItems[msg.sender][address(_tokenAddress)].contains(id),
            "Not listed"
        );
        _;
    }

    modifier isNotStored(IERC721 _tokenAddress, uint256 id) {
        require(
            !supportedTokenTypes.contains(address(_tokenAddress)) ||
                !storedItems[msg.sender][address(_tokenAddress)].contains(id),
            "Already listed"
        );
        _;
    }

    modifier isOwner(IERC721 _tokenAddress, uint256 id) {
        require(
            storedItemsOwners[address(_tokenAddress)][id] == msg.sender,
            "Access denied"
        );
        _;
    }

    modifier tokenNotBanned(IERC721 _tokenAddress) {
        require(
            isTokenSupported(_tokenAddress),
            "Error"
        );
        _;
    }

    modifier notBridged(IERC721 _tokenAddress, uint256 id) {
         require(
            bridgeTransfers[bridgeTransfersOfNFTs[address(_tokenAddress)][id]].status == BRIDGE_STATUS_NONE,
            "Pending bridge"
        );
        _;
    }

     modifier bridgeEnabled(uint8 targetChain) {
         require(
            _bridgeEnabled[targetChain],
            "bridging disabled"
        );
        _;
    }

    modifier noPendingBridge(){
         require(
            bridgeTransfers[bridgeTransfersOfPlayers[msg.sender]].status == BRIDGE_STATUS_NONE
            || bridgeTransfers[bridgeTransfersOfPlayers[msg.sender]].status == BRIDGE_STATUS_DONE,
            "Cannot request a bridge"
        );
        _;
    }
    
    modifier ownsBridgedNFT(uint256 bridgedNFT) {
         require( bridgedTransfers[bridgedNFT].owner == msg.sender, "not bridged NFT owner" );
        _;
    }
    
    // fail safes
    modifier canWithdrawBridgedNFT(uint256 bridgedNFT) {
         require( bridgedTransfers[bridgedNFT].status == BRIDGED_STATUS_AVAILABLE, "not available" );
         require( nftTypeToAddress[bridgedTransfers[bridgedNFT].nftType] != address(0), "NFT not defined" );
        _;
    }


    function isTokenSupported(IERC721 _tokenAddress) public view returns (bool) {
        return supportedTokenTypes.contains(address(_tokenAddress));
    }

    function getSupportedTokenTypes() public view returns (IERC721[] memory) {
        EnumerableSet.AddressSet storage set = supportedTokenTypes;
        IERC721[] memory tokens = new IERC721[](set.length());

        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i] = IERC721(set.at(i));
        }
        return tokens;
    }

    // Get # of stored items of player for NFT
    function getNumberOfStoragedItems(
        IERC721 _tokenAddress
    ) public view returns (uint256) {
        return storedItems[msg.sender][address(_tokenAddress)].length();
    }

    // Get stored items of player for NFT
    function getStorageItemIds(
        IERC721 _tokenAddress
    ) public view  returns (uint256[] memory tokens) {

        uint256 amount = getNumberOfStoragedItems(_tokenAddress);
        tokens = new uint256[](amount);

        EnumerableSet.UintSet storage storedTokens = storedItems[msg.sender][address(_tokenAddress)];

        uint256 index = 0;
        for (uint256 i = 0; i < storedTokens.length(); i++) {
            uint256 id = storedTokens.at(i);
                tokens[index++] = id;
        }
    }

    // Player adds NFT to storage
    function storeItem(
        IERC721 _tokenAddress,
        uint256 _id
    )
        public
        tokenNotBanned(_tokenAddress)
        isNotStored(_tokenAddress, _id)
    {
        storedItems[msg.sender][address(_tokenAddress)].add(_id);
        allStoredItems[address(_tokenAddress)].add(_id);
        storedItemsOwners[address(_tokenAddress)][_id] = msg.sender;

        _tokenAddress.safeTransferFrom(msg.sender, address(this), _id);

        emit NFTStored(msg.sender, _tokenAddress, _id);
    }

    // Player withdraws NFT from storage.
    function withdrawFromStorage(IERC721 _tokenAddress, uint256 _id)
        public
        isStored(_tokenAddress, _id)
        isOwner(_tokenAddress, _id)
        notBridged(_tokenAddress, _id)
    {
        storedItems[msg.sender][address(_tokenAddress)].remove(_id);
        allStoredItems[address(_tokenAddress)].remove(_id);
        delete storedItemsOwners[address(_tokenAddress)][_id];

        _tokenAddress.safeTransferFrom(address(this), msg.sender, _id);

        emit NFTWithdrawn(msg.sender, _tokenAddress, _id);
    }

    function allowToken(IERC721 _tokenAddress) public restricted {
        supportedTokenTypes.add(address(_tokenAddress));
    }

    function disallowToken(IERC721 _tokenAddress) public restricted {
        supportedTokenTypes.remove(address(_tokenAddress));
    }

    // something
    function onERC721Received(
        address, /* operator */
        address, /* from */
        uint256 _id,
        bytes calldata /* data */
    ) external override returns (bytes4) {
        // NOTE: The contract address is always the message sender.
        address _tokenAddress = msg.sender;

        require(
            supportedTokenTypes.contains(_tokenAddress) &&
                allStoredItems[_tokenAddress].contains(_id),
            "Token ID not listed"
        );

        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    // bridge stuff
    function chainBridgeEnabled(uint8 chainId) public view returns (bool) {
        return _bridgeEnabled[chainId];
    }

    // Admin nerd stuff. Should group them.
    function toggleChainBridgeEnabled(uint8 chainId, bool enable) public restricted {
        _bridgeEnabled[chainId] = enable;
    }

    // Player requests to bridge an item
    function bridgeItem(
        IERC721 _tokenAddress,
        uint256 _id,
        uint8 targetChain
    )
        public
        tokenNotBanned(_tokenAddress)
        isStored(_tokenAddress, _id)
        isOwner(_tokenAddress, _id) // isStored built in but why not
        bridgeEnabled(targetChain)
        noPendingBridge()
    {
        bridgeTransfers[++_bridgeTransfers] = BridgeTransfer(msg.sender, address(_tokenAddress), block.number, 0, _id, targetChain, 1);
        bridgeTransfersOfPlayers[msg.sender] = _bridgeTransfers;
        bridgeTransfersOfNFTs[address(_tokenAddress)][_id] = _bridgeTransfers;

        emit NFTBridgeRequest(msg.sender, _tokenAddress, _id);
    }

    // Player cancels bridge request. Can only happen if it's pending.
    function cancelBridge() public
    {
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransfersOfPlayers[msg.sender]];

        require(bridgeTransfer.status == BRIDGE_STATUS_PENDING, 'no pending bridge');
        bridgeTransfer.status = BRIDGE_STATUS_NONE;
        bridgeTransfer.lastUpdateBlock = block.number;

        emit NFTBridgeCancel(msg.sender);
    }

    // Player received NFTs waiting to be converted to NFTs
    function getReceivedNFTs() public view  returns (uint256[] memory tokens) {
        uint256 amount = receivedNFTs[msg.sender].length();
        tokens = new uint256[](amount);

        EnumerableSet.UintSet storage storedTokens = receivedNFTs[msg.sender];

        uint256 index = 0;
        for (uint256 i = 0; i < storedTokens.length(); i++) {
            uint256 id = storedTokens.at(i);
                tokens[index++] = id;
        }
    }

    function getReceivedNFT(uint256 receivedNFT) public view  returns (address, uint8, uint8, uint256, uint8, uint256) {
        BridgedTransfer storage bridgedTransfer = bridgedTransfers[receivedNFT];
        return (bridgedTransfer.owner, bridgedTransfer.nftType, bridgedTransfer.sourceChain, bridgedTransfer.sourceId, bridgedTransfer.status, bridgedTransfersMeta[receivedNFT]);
    }

    // Convert data stored by bot into an actual NFT and move it to storage
    // Bot can't mint on its own because some NFTs will have constraints (example max 4 chars)
    // Storage concept makes it a lot easier
    function withdrawFromBridge(uint256 bridgedNFT) ownsBridgedNFT(bridgedNFT) canWithdrawBridgedNFT(bridgedNFT) public {
        uint256 mintedItem;
        BridgedTransfer storage bridgedTransfer = bridgedTransfers[bridgedNFT];
        uint256 seed = 0;//randoms.getRandomSeed(bridgedTransfer.owner);

        if(bridgedTransfer.nftType == NFT_TYPE_WEAPON){
            mintedItem = _withdrawWeaponFromBridge(bridgedTransfersMeta[bridgedNFT], seed);
        }
        else if(bridgedTransfer.nftType == NFT_TYPE_CHARACTER) {
            mintedItem = _withdrawCharacterFromBridge(bridgedTransfersMeta[bridgedNFT], seed);
        }

        address nftAddress = nftTypeToAddress[bridgedTransfer.nftType];
        allStoredItems[nftAddress].add(mintedItem);
        storedItemsOwners[nftAddress][mintedItem] = bridgedTransfer.owner;
        storedItems[bridgedTransfer.owner][nftAddress].add(mintedItem);

        receivedNFTs[msg.sender].remove(bridgedNFT);
        bridgedTransfers[bridgedNFT].status = BRIDGED_STATUS_WITHDRAWN;
        bridgedTransfers[bridgedNFT].lastUpdateBlock = block.number;

        emit NFTBridgedOut(bridgedTransfer.owner, bridgedNFT, bridgedTransfer.nftType, mintedItem);
    }

    function _withdrawWeaponFromBridge(uint256 metaData, uint256 seed) internal returns (uint256 mintedId) {
        (uint16 properties, uint16 stat1, uint16 stat2, uint16 stat3, uint8 lowStarBurnPoints, uint8 fourStarBurnPoints, uint8 fiveStarBurnPoints) 
            = unpackWeaponsData(metaData);

        mintedId = 
            weapons.performMintWeapon(address(this), properties, 
            stat1, stat2, 
            stat3, seed);

            weapons.setBurnPoints(mintedId, lowStarBurnPoints, fourStarBurnPoints, fiveStarBurnPoints);
    }

    function _withdrawCharacterFromBridge(uint256 metaData, uint256 seed) internal returns (uint256 mintedId) {
        (uint16 xp, uint8 level, uint8 trait)  = unpackCharactersData(metaData); 
        mintedId = 
            characters.customMint(address(this), xp, 
            level, trait, seed);
    }

    // Bot stuff
    function botEnabled() public view returns (bool){
        return _botEnabled;
    }

    function toggleBotEnabled(bool enable) public restricted {
        _botEnabled = enable;
    }

    function getBridgeTransferAt() public view returns (uint256){
        return _bridgeTransfersAt;
    }

    function setBridgeTransferAt(uint256 bridgeTransfersAt) public gameAdminRestricted {
        _bridgeTransfersAt = bridgeTransfersAt;
    }

    function getBridgeTransfers() public view returns (uint256){
        return _bridgeTransfers;
    }

    // Transfer request of a player if any (only active one). Not bot... will move up
    function getBridgeTransfer() public view returns (uint256){
        return bridgeTransfersOfPlayers[msg.sender];
    }

    function getBridgeTransfer(uint256 bridgeTransferId) public returns (address, address, uint256, uint256, uint256, uint8, uint8) {
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransferId];
        return (bridgeTransfer.owner,
                bridgeTransfer.nftAddress,
                bridgeTransfer.nftId,
                bridgeTransfer.requestBlock,
                bridgeTransfer.lastUpdateBlock,
                bridgeTransfer.chainId,
                bridgeTransfer.status);
    }

    // Bot to update status of a transfer request (this chain => outside chain)
    function updateBridgeTransferStatus(uint256 bridgeTransferId, uint8 status, bool forced) public gameAdminRestricted {
        BridgeTransfer storage bridgeTransfer = bridgeTransfers[bridgeTransferId];
        require(forced || 
        (bridgeTransfer.status == BRIDGE_STATUS_PENDING && status == BRIDGE_STATUS_PROCESSING)
        || (bridgeTransfer.status == BRIDGE_STATUS_PROCESSING && status == BRIDGE_STATUS_DONE)
        || status == BRIDGE_STATUS_ERROR, 'Invalid status change');
        bridgeTransfer.status = status;
        bridgeTransfer.lastUpdateBlock = block.number;

        emit NFTBridgeUpdate(bridgeTransferId, status, forced);
    }

    // Bot to transfer in an NFT (outside chain => this chain)
    function transferIn(address receiver, uint8 nftType, uint8 sourceChain, uint256 sourceId, 
    string memory rename, uint256 metaData) public gameAdminRestricted {
        bridgedTransfers[++_bridgedTransfersAt] = BridgedTransfer(receiver, nftType, sourceChain, sourceId,
        rename, block.number, 0, BRIDGED_STATUS_AVAILABLE);
        receivedNFTs[receiver].add(_bridgedTransfersAt);
        bridgedTransfersMeta[_bridgedTransfersAt] = metaData;

        emit TransferIn(receiver, nftType, sourceChain, sourceId);
    }

    function packWeaponsData(uint16 properties, uint16 stat1, uint16 stat2, uint16 stat3, uint8 lowStarBurnPoints, uint8 fourStarBurnPoints, uint8 fiveStarBurnPoints) public pure returns (uint256){
        return  uint256(fiveStarBurnPoints | (uint256(fourStarBurnPoints) << 8) | (uint256(lowStarBurnPoints) << 16) | (uint256(stat3) << 24) | (uint256(stat2) << 40) | (uint256(stat1) << 56) | (uint256(properties) << 72));
    }

    function unpackWeaponsData(uint256 metaData) public pure returns (uint16 properties, uint16 stat1, uint16 stat2, uint16 stat3, uint8 lowStarBurnPoints, uint8 fourStarBurnPoints, uint8 fiveStarBurnPoints) {
        fiveStarBurnPoints = uint8(metaData & 0xFF);
        fourStarBurnPoints = uint8((metaData >> 8) & 0xFF);
        lowStarBurnPoints = uint8((metaData >> 16) & 0xFF);
        stat3 = uint16((metaData >> 24) & 0xFFFF);
        stat2 = uint16((metaData >> 40) & 0xFFFF);
        stat1 = uint16((metaData >> 56) & 0xFFFF);
        properties = uint16((metaData >> 72) & 0xFFFF);
    }

    function packCharactersData(uint16 xp, uint8 level, uint8 trait) public pure returns (uint256){
        return  uint256(uint256(trait) | (uint256(level) << 8) | (uint256(xp) << 16));
    }

    function unpackCharactersData(uint256 metaData) public pure returns (uint16 xp, uint8 level, uint8 trait) {
        trait = uint8((metaData) & 0xFF);
        level = uint8((metaData >> 8) & 0xFF);
        xp = uint16(metaData  >> 16 & 0xFFFF);
    }
}
