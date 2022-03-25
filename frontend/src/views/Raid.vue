<template>
  <div class="main-font">
    <div class="row">
       <div class="col-md-12 col-lg-12">
        <div class="row">
          <div class="col-lg-12" id="raid-header">
            <div class="row">
              <div class="col-lg-4">
                <div class="boss-list">
                  <img :src="getBossArt(raidIndex)" class="img-responsive" />
                </div>
              </div>
              <div class="col-lg-6">
                <div class="boss-details">
                  <div>
                    <span :class="traitNumberToName(bossTrait).toLowerCase() + '-icon trait-icon'" />
                    <div class="boss-name">
                        <h3>{{ bossName }}</h3>
                        <div>
                          <span>{{$t('raid.title')}}</span> &nbsp; | &nbsp;
                          <span>{{ traitNumberToName(bossTrait).toLowerCase() }} Element</span> |
                          <span>+{{ xpReward }} EXP</span>
                        </div>
                    </div>
                  </div>
                  <div class="boss-history">
                    Messenger ravens flood the skies with news of the Seers visions. Heralds are heard throughout the cities and towns proclaiming.
                    “All ye that are able of body and strong of heart are called upon to serve in the kings legion to combat a new enemy"
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-lg-12">
             <div class="row raid-power">
              <div class="col-lg-4">
                <div class="row">
                  <div class="col-lg-12 nav-raid">
                    <div>
                      <p>PREPARATON</p>
                    </div>
                  </div>
                    <div class="col-lg-12 powers">
                      <div>
                        <span>Multiplier</span>
                        <p>x{{ currentMultiplier }}</p>
                      </div>
                      <div style="border-right:none">
                        <span>Power</span>
                        <p>{{ currentCharacterPower }}</p>
                      </div>
                  </div>
                  <div class="col-lg-12 drops">
                     <span>Character</span>
                     <div class="char-info">
                        <div  div class="art" :style="'background-image: url('+getCharacterArt(currentCharacter)+')'">
                            .
                        </div>
                        <div>
                          <!-- <img :src="getCharacterArt(currentCharacter)" alt="KNIGHTS"> -->
                          <p class="name bold character-name"> {{getCleanCharacterName(currentCharacterId)}} </p>
                          <span class="subtext subtext-stats">
                            <p style="text-transform:capitalize"><span :class="traitNumberToName(currentCharacter.trait).toLowerCase()
                            + '-icon trait-icon char-icon'" /> {{ traitNumberToName(currentCharacter.trait).toLowerCase() }} Element</p>
                            <span><b>{{$t('CharacterDisplay.level')}}{{ currentCharacter.level + 1 }}</b></span>
                          </span>
                        </div>
                      </div>
                  </div>
                  <div class="col-lg-12 drops">
                     <span>Weapon</span>
                     <div class="weapon-info col-sm-6" v-if="selectedWeapon">
                       <div>
                          <weapon-inventory class="weapon-icon" :weapon="selectedWeapon" :displayType="'raid'"/>
                       </div>
                       <div @click="changeEquipedWeapon()">
                          <img src="../assets/swithc-wep.png" alt="">
                       </div>
                     </div>
                     <div class="weapon-info col-sm-6" v-else>
                       <div class="outline-box">
                          <div>
                            <div @click="changeEquipedWeapon()">
                              <img src="../assets/swithc-wep.png" alt="">
                            </div>
                          </div>
                          <div>
                            <p>No Weapon</p>
                            <span>Click the icon to equip a weapon</span>
                          </div>
                       </div>
                     </div>
                  </div>
                </div>
              </div>
              <div class="col-lg-8">
                <div class="row">
                  <div class="col-lg-12 nav-raid">
                    <div>
                      <p>RAID SIGNUP</p>
                    </div>
                    <div>
                      <p>HISTORY</p>
                    </div>
                  </div>
                  <div class="col-lg-12 powers">
                      <div>
                        <span>{{$t('raid.numberOfRaiders')}}</span>
                        <p>{{ raiderCount }}</p>
                      </div>
                      <div>
                        <span>{{$t('raid.totalPower')}}</span>
                        <p>{{ totalPower }}</p>
                      </div>
                      <div>
                        <span>{{$t('raid.bossPower')}}</span>
                        <p>{{ bossPower }}</p>
                      </div>
                      <div>
                        <span> {{$t('raid.victoryChance')}}</span>
                        <p>{{ formattedWinChance }}</p>
                      </div>
                  </div>
                  <div class="col-lg-12 drops">
                    <span>Chance to {{$t('raid.drops')}}</span>
                      <div class="drops-icons">
                        <nft-icon :isDefault="true" :nft="{ type: 'weapon' }" />
                        <nft-icon :isDefault="true" :nft="{ type: 'trinket' }"/>
                        <nft-icon :isDefault="true" :nft="{ type: 'junk' }"/>
                        <nft-icon :isDefault="true" :nft="{ type: 'secret' }"/>
                        <nft-icon :isDefault="true" :nft="{ type: 'lbdust' }"/>
                        <nft-icon :isDefault="true" :nft="{ type: '4bdust' }"/>
                        <nft-icon :isDefault="true" :nft="{ type: '5bdust' }"/>
                      </div>
                  </div>
                  <div class="col-lg-12 join-raid">
                    <button class="btn-raid"  v-tooltip="$t('raid.joiningCostStamina', {formatStaminaHours})" @click="joinRaidMethod()">
                      JOIN RAID
                      <span>{{remainingTime}}</span>
                    </button>
                    <div>
                      <p>Joining will cost</p>
                      <span>{{ staminaCost }} {{$t('raid.stamina')}}</span>|
                      <span>{{ durabilityCost }} {{$t('raid.durability')}}</span> |
                      <span>
                        <CurrencyConverter
                        :skill="convertWeiToSkill(joinCost)"
                        :minDecimals="0"
                        :maxDecimals="5"/>
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- <div class="row">
      <div class="col-md-12 col-lg-12">
        <span class="bold raid-title-section">{{$t('raid.title')}}</span>
        <hr class="divider">
        <div class="row boss-row">
          <div class="col-md-12 col-lg-6 order-xs-last order-sm-last order-lg-first">
            <ul class="list-group raid-details mb-4">
              <li class="list-group-item d-flex justify-content-between align-items-center raid-details-text">
                {{$t('raid.numberOfRaiders')}}
                <span class="badge badge-primary badge-pill">{{ raiderCount }}</span>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center raid-details-text">
                {{$t('raid.totalPower')}}
                <span class="badge badge-primary badge-pill">{{ totalPower }}</span>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center raid-details-text">
                 {{$t('raid.bossPower')}}
                <span class="badge badge-primary badge-pill">{{ bossPower }}</span>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center raid-details-text progress-container">
                <div class="d-flex justify-content-between align-items-center raid-details-text" style="width: 100%;">
                {{$t('raid.victoryChance')}}
                <span class="badge badge-primary badge-pill">{{ formattedWinChance }}</span>
                </div>
                <div class="progress" style="width: 100%">
                  <div class="progress-bar progress-bar-striped progress-bar-animated players-progress-bar"
                    role="progressbar" :style="[{'width': calculatePlayersProgressBarWidth(), 'background-color': calculateProgressBarColor()}]"></div>
                  <div class="progress-bar progress-bar-striped progress-bar-animated bg-danger boss-progress-bar"
                    role="progressbar" :style="[{'width': calculateBossProgressBarWidth() }]"></div>
                </div>
              </li>
            </ul>
            <span class="mt-3 bold raid-title-section">
              {{$t('raid.drops')}}
              <b-icon-question-circle class="rewards-tooltip"
               v-tooltip="$t('raid.rewardsHint')"/>
            </span>
            <hr class="divider">
            <div class="drops">
              <div class="drops-icons">
                <nft-icon :isDefault="true" :nft="{ type: 'weapon' }" />
                <nft-icon :isDefault="true" :nft="{ type: 'trinket' }"/>
                <nft-icon :isDefault="true" :nft="{ type: 'junk' }"/>
                <nft-icon :isDefault="true" :nft="{ type: 'secret' }"/>
                <nft-icon :isDefault="true" :nft="{ type: 'lbdust' }"/>
                <nft-icon :isDefault="true" :nft="{ type: '4bdust' }"/>
                <nft-icon :isDefault="true" :nft="{ type: '5bdust' }"/>
              </div>
              <br />
              <span class="bold raid-title-section xp-reward-section">
                {{$t('raid.xpReward')}} </span> <span class="xp-reward ml-3 raid-details-text"> {{ xpReward }}
                <b-icon-question-circle
                  v-tooltip="$t('raid.xpRewardHint')"/>
              </span>
            </div>
          </div>
          <div class="col-xs-12 col-sm-12 col-md-12 col-lg-6 order-xs-first order-sm-first boss-col">
            <div class="boss-box">
              <div class="raid-title">
                <span class="title mr-3"> #{{ raidIndex }} {{ bossName }} </span>
                <span :class="traitNumberToName(bossTrait).toLowerCase() + '-icon trait-icon'" />
              </div>
              <div class="img-responsive boss-img">
                <img :src="getBossArt(raidIndex)" class="img-responsive" />
              </div>
            </div>
          </div>
        </div>
        <hr class="divider">
      </div>
      <div class="col-md-12 col-lg-6">
        <div class="row">
          <div class="col-xs-12 col-sm-12 col-lg-6 weap-box">
            <span class="raid-title-section bold">
              <span>{{$t('raid.weapon')}}
                <Hint
                :text="$t('raid.weaponHint')"/>
                  </span>
                  <span class="float-right sub-text">
                    {{$t('raid.multiplier')}}{{ currentMultiplier }}
                  </span>
              </span>
              <hr class="divider">
            <div class="header-row">
              <div v-if="selectedWeaponId" class="weapon-icon-wrapper">
                <weapon-icon class="weapon-icon" :weapon="getSelectedWeapon" />
              </div>
              <b-button v-if="selectedWeaponId" variant="primary" class="new-weapon-button" @click="selectedWeaponId = null">
                {{$t('raid.chooseNewWeapon')}}
              </b-button>
            </div>

            <weapon-grid v-if="!selectedWeaponId" v-model="selectedWeaponId" class="raid-weapon-grid">
              <template #sold="{ weapon: { id } }">
                <div class="sold" v-if="participatingWeapons && participatingWeapons.find(x => +x === +id) !== undefined">
                  <span>{{$t('raid.inRaid')}}</span>
                </div>
              </template>
            </weapon-grid>
            <hr class="divider">
          </div>
          <div class="col-xs-12 col-sm-12 col-lg-6 char-box">
            <span class="raid-title-section bold">{{$t('raid.character')}}
              <span class="float-right sub-text">{{$t('raid.power')}} {{ currentCharacterPower }}</span>
            </span>
            <hr class="divider">
            <character-list :value="currentCharacterId" @input="setCurrentCharacter" class="raid-style">
              <template #sold="{ character: { id } }">
                <div class="sold" v-if="participatingCharacters && participatingCharacters.find(x => +x === +id) !== undefined">
                  <span>{{$t('raid.inRaid')}}</span>
                </div>
              </template>
            </character-list>
            <hr class="divider">
          </div>
        </div>
      </div>
    </div> -->
    <!-- <div class="container">
      <div class="row">
        <div class="col-12">
          <div class="text-center">
            {{$t('raid.joiningCost')}} <span class="badge badge-secondary">{{ staminaCost }}
            {{$t('raid.stamina')}} </span>,
            <span class="badge badge-secondary">{{ durabilityCost }}
            {{$t('raid.durability')}} </span> {{$t('raid.and')}}
            <span class="badge badge-secondary"><CurrencyConverter :skill="convertWeiToSkill(joinCost)" :minDecimals="0"
                                                                   :maxDecimals="5"/></span>
          </div>
        </div>
      </div>
    </div> -->
    <b-modal id="rewardsModal" hide-footer hide-header>
     <div>
        <div class="tob-bg-img promotion-decoration">
          <img class="vertical-decoration bottom" src="../assets/header-ads.png">
        </div>
      <div class="results-panel">
        <div class="float-center">
          <h1 class="text-center outcome pt-4 pb-2">{{$t('raid.raidSuccess')}}</h1>
              <b-col class="you-earned-raid text-center">
                <h4>{{$t('raid.gotXP', {xpReward})}}</h4>
              </b-col>
          <b-container v-if="bonuxXpCharacterNames && bonuxXpCharacterNames.length > 0">
            <b-row>
              <b-col cols="12"  lg="12" sm="12" md="12" class="win-details">
                <h5 class="ins">{{$t('raid.gotBonusXP')}}</h5>
              </b-col>
            </b-row>
          </b-container>
          <b-container v-if="bonuxXpCharacterNames && bonuxXpCharacterNames.length > 0">
            <b-row class="power-rolled" v-for="i in bonuxXpCharacterNames.length" :key="i">
              <b-col cols="4" lg="5" sm="4" md="4" class="win-details">
                <h5> {{bonuxXpCharacterNames[i - 1]}}</h5>
              </b-col>
              <b-col cols="4" lg="2" sm="4" md="4" class="win-details">
                <img src="../assets/arrow-right.png" alt="">
              </b-col>
              <b-col cols="4" lg="5" sm="4" md="4" class="win-details">
                <h5>+{{bonuxXpAmounts[i - 1]}} XP</h5>
              </b-col>
            </b-row>
        </b-container>
          <b-container>
            <b-row>
              <b-col class="earned" lg="12">
                <h5>{{$t('raid.loot')}}</h5>
              </b-col>
              <b-col lg="12">
                <nft-list :showGivenNftIdTypes="true" :nftIdTypes="rewards" :isReward="true"/>
              </b-col>
            </b-row>
          </b-container>
          <button class="btn-raid" style="margin:auto">
            {{$t('raid.claimRewards')}}
          </button>
        </div>
      </div>
        <div class="bot-bg-img promotion-decoration">
          <img src="../assets/separator.png">
        </div>
      </div>
      <div class="footer-close">
          <p class="tap"> {{$t('combat.tabAnywhere')}}</p>
          <span @click="$bvModal.hide('rewardsModal')"><img style="margin: auto;width: 40px !important;" src="../assets/close-btn.png" alt=""></span>
      </div>
    </b-modal>

    <!-- JUST NEED TO COMMENT HERE TO MAKE SURE I MAKING IT RIGHT -->
    <!-- <div class="row">
      <div class="col-sm-12">
        <div class="raid-info-box mt-3">
          <div class="row raid-summary-container"> -->
            <!-- <div class='col-sm-4 raid-summary-text'>
              <div class="float-lg-left mb-sm-2">
                <div class="finish">
                    <span class="title">{{$t('raid.finishesOn')}}</span>
                    {{ expectedFinishTime }}
                    <br />
                    <span class="title">{{$t('raid.raidStatus')}}</span> {{ raidStatus }}
                  </div>
              </div>
            </div> -->
            <!-- <div class="col-sm-8 row">
              <big-button v-if="claimButtonActive" class="encounter-button btn-styled" :mainText="$t('raid.claimRewards')" @click="promptRewardClaim()" />
              <b-modal id="rewardsRaidPicker" :title="$t('raid.raidRewardsSelector')" @ok="claimRewardIndex(rewardsRaidId)">
                <div class="raid-picker">
                  {{$t('raid.selectRaid')}}
                  <select class="form-control raid-id-selector" v-model="rewardsRaidId">
                    <option v-for="id in rewardIndexes" :value="id" :key="id">{{ id }}</option>
                  </select>
                </div>
              </b-modal>
              <big-button class="encounter-button btn-styled" :mainText="$t('raid.signUp')"
                     v-tooltip="$t('raid.joiningCostStamina', {formatStaminaHours})" @click="joinRaidMethod()" />
            </div> -->
            <!-- <div class='col-sm-4 raid-summary-text'>
             <div class="float-lg-right text-sm-center mt-sm-2 text-center">
                <div class="finish">
                    <span class="title">{{$t('raid.yourPower')}}  {{accountPower}}</span>
                  </div>
              </div>
            </div> -->
          <!-- </div>
          </div>
        </div>
    </div> -->
 </div>
</template>
<script lang="ts">

import Vue from 'vue';
import {mapActions, mapGetters, mapMutations, mapState} from 'vuex';
import { getCharacterArt } from '../character-arts-placeholder';
import NftIcon from '@/components/NftIcon.vue';
import NftList, {NftIdType} from '@/components/smart/NftList.vue';
import WeaponInventory from '../components/WeaponInvetory.vue';
import CurrencyConverter from '../components/CurrencyConverter.vue';
import {GetTotalMultiplierForTrait, IWeapon} from '@/interfaces/Weapon';
import {IRaidState, IState} from '@/interfaces';
import {getBossArt} from '@/raid-boss-art-placeholder';
import {traitNumberToName} from '@/contract-models';
import {fromWeiEther, toBN} from '@/utils/common';
import {staminaToHours} from '@/utils/date-time';
import {BonusXp, Dust4b, Dust5b, DustLb, Junk, Keybox, RaidRewards, Weapon} from '@/interfaces/RaidRewards';
import i18n from '@/i18n';
import Events from '../events';
import { getCleanName } from '../rename-censor';
import BigNumber from 'bignumber.js';

interface RaidMappedActions {
  fetchRaidState(): Promise<void>;
  joinRaid(payload: { characterId: string, weaponId: string}): Promise<void>;
  fetchRaidRewards(payload: {startIndex: number, endIndex: string }): Promise<string[]>;
  claimRaidRewards(payload: { rewardIndex: string }): Promise<RaidRewards>;
  fetchRaidingCharacters(): Promise<string[]>;
  fetchRaidingWeapons(): Promise<string[]>;
  fetchIsRaidStarted(): Promise<boolean>;
  canUserAfford(payload: { payingAmount: BigNumber }): Promise<boolean>;
  fetchHaveEnoughEnergy(payload: { characterID: string, weaponID: string }): Promise<boolean>;
  fetchIsCharacterRaiding(payload: { characterID: string }): Promise<boolean>;
  fetchIsWeaponRaiding(payload: { weaponID: string }): Promise<boolean>;
  fetchCharacters(payload: { characterIds: (string | number)[]}): Promise<void>;
}

interface RaidMappedMutations {
  setCurrentCharacter(state: IState, characterId: number): void;
}

interface RaidMappedGetters {
  getRaidState(): IRaidState;
}

let interval: number;

const dragonNames = [
  'Fudbringer',
  'HODL Lord',
  'Skill Eater',
  'Chain Congester',
  'Swap Guardian',
  'Blade Hoarder',
  'Centralizer',
  'Exchange Tormentor',
  'Eater of Stakes',

  // 'M13',
  // 'Ste1n',
  // 'Moneth',
  // 'Skulpin',
  // 'Plitszkin',

  // 'KokMhei',
  // 'kocuZe',
  // 'Jestinsane',
  // 'Krypton',
  // 'Richard Melics',
];

const moment = require('moment');
const bossImages = [
  '../assets/raid-bosses/CB_Hellborn Brute.gif',
  '../assets/raid-bosses/CB_Hellborn Executioner.gif',
  '../assets/raid-bosses/CB_Hellborn Marauder.gif',
  '../assets/raid-bosses/CB_Hellborn Overlord.gif',
  '../assets/raid-bosses/CB_Hellborn Shaman.gif',

  // '../assets/raid-bosses/CB_Hellborn M13.gif',
  // '../assets/raid-bosses/CB_Hellborn Ste1n.gif',
  // '../assets/raid-bosses/CB_Hellborn Moneth.gif',
  // '../assets/raid-bosses/CB_Hellborn Skulpin.gif',
  // '../assets/raid-bosses/CB_Hellborn Plitszkin.gif',

  // '../assets/raid-bosses/KokMhei.gif',
  // '../assets/raid-bosses/KocuZe.gif',
  // '../assets/raid-bosses/Jestinsane.gif',
  // '../assets/raid-bosses/Krypton.gif',
  // '../assets/raid-bosses/Melics.gif',
];

export default Vue.extend({
  data() {
    return {
      selectedWeaponId: '',
      selectedWeapon: null,
      raidIndex: '',
      bossName: '',
      raiderCount: '',
      totalPower: '',
      expectedFinishTime: '',
      xpReward: '',
      staminaCost: '',
      durabilityCost: '',
      joinCost: '',
      raidStatus: '',
      bossPower: '',
      bossTrait: '',
      accountPower: '',
      rewardsRaidId: '',
      rewardIndexes: [] as string[],
      rewards: [] as NftIdType[],
      spin: false,
      participatingCharacters: [] as string[],
      participatingWeapons: [] as string[],
      bonuxXpCharacterNames: [] as string[],
      bonuxXpAmounts: [] as string[],
      remainingTime: '',
      traits:''
    };
  },

  computed: {
    ...mapState(['characters', 'maxStamina', 'currentCharacterId', 'ownedCharacterIds', 'defaultAccount']),
    ...mapGetters(['ownCharacters', 'ownWeapons', 'currentCharacter',
      'currentCharacterStamina', 'getWeaponDurability', 'contracts', 'getCharacterName', 'getCharacterPower']),

    claimButtonActive(): boolean {
      return this.rewardIndexes !== null && this.rewardIndexes.length > 0;
    },

    currentMultiplier(): string {
      if(!this.selectedWeaponId) return '0';
      const currentWeapon = this.ownWeapons.find((weapon: IWeapon) => weapon.id === +this.selectedWeaponId);
      if(!currentWeapon) return '0';
      return GetTotalMultiplierForTrait(currentWeapon, this.currentCharacter.trait).toFixed(2);
    },

    currentCharacterPower(): number {
      if(!this.currentCharacter) return 0;
      return this.getCharacterPower(this.currentCharacter.id);
    },

    getSelectedWeapon(): IWeapon {
      return this.ownWeapons.find((weapon: IWeapon) => weapon.id === +this.selectedWeaponId);
    },

    formatStaminaHours(): string {
      return staminaToHours(+this.staminaCost).toFixed(1);
    },

    formattedWinChance(): string {
      return `${this.calculateWinChance()}%`;
    }
  },

  methods: {
    getBossArt,
    traitNumberToName,
    ...(mapActions([
      'fetchRaidState',
      'joinRaid',
      'fetchRaidRewards',
      'claimRaidRewards',
      'fetchRaidingCharacters',
      'fetchRaidingWeapons',
      'fetchIsRaidStarted',
      'fetchHaveEnoughEnergy',
      'fetchIsCharacterRaiding',
      'fetchIsWeaponRaiding',
      'fetchCharacters',
      'canUserAfford'
    ]) as RaidMappedActions),
    ...(mapMutations([
      'setCurrentCharacter'
    ]) as RaidMappedMutations),
    ...(mapGetters([
      'getRaidState',
    ]) as RaidMappedGetters),

    calculateWinChance(): string {
      return (Math.min(Math.max(+this.totalPower / +this.bossPower / 2 * 100, 0), 99.99)).toFixed(2);
    },
    getCharacterArt,
    calculateProgressBarColor(): string {
      if(+this.calculateWinChance() < 30){
        return '#ccae4f';
      } else if (+this.calculateWinChance() < 70){
        return 'blue';
      } else {
        return 'green';
      }
    },

    changeEquipedWeapon(){
      Events.$emit('weapon-inventory', true);
    },

    getTimeRemaining(){
      const eventTime = moment('2022-03-25');
      const currentTime = moment(new Date());
      const diffTime = eventTime - currentTime;
      const interval = 1000;
      let duration = moment.duration(diffTime * 1000, 'milliseconds');

      setInterval(() => {
        duration = moment.duration(duration - interval, 'milliseconds');
        this.remainingTime = duration.days() +' days '+duration.hours() + ' hrs ' + duration.minutes() + ' mins ' + duration.seconds() + 'sec';
      }, interval);
    },

    getCleanCharacterName(id: string): string {
      return getCleanName(this.getCharacterName(id));
    },

    calculatePlayersProgressBarWidth(): string {
      return `${Math.round(+this.calculateWinChance())}%`;
    },

    calculateBossProgressBarWidth(): string {
      return `${Math.round(100 - +this.calculateWinChance())}%`;
    },

    convertWeiToSkill(wei: string): string {
      return fromWeiEther(wei);
    },

    weaponHasDurability(id: number): boolean{
      return this.getWeaponDurability(id) > 0;
    },

    async joinRaidMethod(): Promise<void> {
      const canUserAfford = await this.canUserAfford({payingAmount: toBN(this.joinCost)});
      if(!canUserAfford) {
        (this as any).$dialog.notify.error(i18n.t('raid.errors.cannotAffordRaid'));
        return;
      }

      if (!this.selectedWeaponId || !this.currentCharacterId) {
        (this as any).$dialog.notify.error(i18n.t('raid.errors.selection'));
        return;
      }

      const isRaidStarted = await this.isRaidStarted();
      if(!isRaidStarted) {
        (this as any).$dialog.notify.error(i18n.t('raid.errors.raidNotStarted'));
        return;
      }
      const isCharacterRaiding = await this.isCharacterAlreadyRaiding(this.currentCharacterId);
      if(isCharacterRaiding) {
        (this as any).$dialog.notify.error(i18n.t('raid.errors.lockedChar'));
        return;
      }
      const isWeaponRaiding = await this.isWeaponAlreadyRaiding(this.selectedWeaponId);
      if(isWeaponRaiding) {
        (this as any).$dialog.notify.error(i18n.t('raid.errors.lockedWeapon'));
        return;
      }
      const haveEnoughEnergy = await this.haveEnoughEnergy(this.currentCharacterId, this.selectedWeaponId);
      if(!haveEnoughEnergy) {
        (this as any).$dialog.notify.error(i18n.t('raid.errors.notEnough'));
        return;
      }

      try {
        await this.joinRaid({ characterId: this.currentCharacterId, weaponId: this.selectedWeaponId});
        this.selectedWeaponId = '';
      } catch (e) {
        console.error(e);
        (this as any).$dialog.notify.error(i18n.t('raid.errors.whoops'));
      }

      await this.getParticipatingCharacters();
      await this.getParticipatingWeapons();
    },

    async getParticipatingCharacters(): Promise<void> {
      // gets the list of this player's raid locked characters
      // TODO store these?
      this.participatingCharacters = await this.fetchRaidingCharacters();
    },

    async getParticipatingWeapons(): Promise<void> {
      // gets the list of this player's raid locked weapons
      // TODO store these?
      this.participatingWeapons = await this.fetchRaidingWeapons();
    },

    async isCharacterAlreadyRaiding(characterID: string): Promise<boolean> {
      return await this.fetchIsCharacterRaiding({
        characterID
      });
    },

    async isWeaponAlreadyRaiding(weaponID: string): Promise<boolean> {
      return await this.fetchIsWeaponRaiding({
        weaponID
      });
    },

    async isRaidStarted(): Promise<boolean> {
      return await this.fetchIsRaidStarted();
    },

    async haveEnoughEnergy(characterID: string, weaponID: string): Promise<boolean>{
      return await this.fetchHaveEnoughEnergy({
        characterID,
        weaponID
      });
    },

    async getRewardIndexes(): Promise<void> {
      if(!this.raidIndex)
        return;
      let startIndex = +this.raidIndex-21; // one week worth
      if(startIndex < 0)
        startIndex = 0;
      const endIndex = this.raidIndex;

      this.rewardIndexes = await this.fetchRaidRewards({
        startIndex,
        endIndex
      });
    },

    promptRewardClaim(): void {
      // should offer a popup here to pick which index to claim
      // if only one index, then claim instantly
      if(this.rewardIndexes !== null && this.rewardIndexes.length > 0) {
        if(this.rewardIndexes.length === 1) {
          this.claimRewardIndex(this.rewardIndexes[0]);
        }
        else {
          (this as any).$bvModal.show('rewardsRaidPicker');
        }
      }
    },

    async claimRewardIndex(rewardIndex: string): Promise<void> {
      this.bonuxXpCharacterNames = [];
      this.bonuxXpAmounts = [];
      const result = await this.claimRaidRewards({
        rewardIndex
      });

      const nfts: NftIdType[] = [];
      if(result.weapons) {
        result.weapons.forEach((x: Weapon) => {
          nfts.push({ type: 'weapon', id: x.tokenID });
        });
      }
      if(result.junks) {
        result.junks.forEach((x: Junk) => {
          nfts.push({ type: 'junk', id: x.tokenID });
        });
      }
      if(result.keyboxes) {
        result.keyboxes.forEach((x: Keybox) => {
          nfts.push({ type: 'keybox', id: x.tokenID });
        });
      }
      if(result.dustLb) {
        result.dustLb.forEach((x: DustLb) => {
          nfts.push({ type: 'dustLb', id: 0, amount: x.amount });
        });
      }
      if(result.dust4b) {
        result.dust4b.forEach((x: Dust4b) => {
          nfts.push({ type: 'dust4b', id: 0, amount: x.amount });
        });
      }
      if(result.dust5b) {
        result.dust5b.forEach((x: Dust5b) => {
          nfts.push({ type: 'dust5b', id: 0, amount: x.amount });
        });
      }
      if(result.bonusXp) {
        result.bonusXp.forEach((x: BonusXp) => {
          this.bonuxXpCharacterNames.push(this.getCharacterName(x.charID));
          this.bonuxXpAmounts.push(x.amount);
        });
      }

      this.rewards = nfts;
      this.spin = true;
      (this as any).$bvModal.show('rewardsModal');
      setTimeout(() => {
        this.spin = false;
      }, 10000);

      await this.fetchCharacters(this.ownedCharacterIds);
    },

    getBossName(): string {
      return dragonNames[+this.raidIndex % dragonNames.length];
    },

    getBossImage(): string {
      return bossImages[+this.raidIndex % bossImages.length];
    },

    processRaidData(): void {
      const raidData = this.getRaidState();
      this.raidIndex = raidData.index;
      this.bossName = this.getBossName();
      this.raiderCount = raidData.raiderCount;
      this.totalPower = raidData.playerPower;
      this.expectedFinishTime = new Date(+raidData.expectedFinishTime * 1000).toLocaleString();
      this.xpReward = raidData.xpReward;
      this.staminaCost = raidData.staminaCost;
      this.durabilityCost = raidData.durabilityCost;
      this.joinCost = raidData.joinSkill;
      this.raidStatus = raidData.status ? 'Preparation' : 'Finished';
      this.bossPower = raidData.bossPower;
      this.bossTrait = raidData.bossTrait;
      this.accountPower = raidData.accountPower;
    }
  },


  async mounted() {
    this.getTimeRemaining();
    const refreshRaidData = async () => {
      await (this as any).getRewardIndexes();
      await (this as any).fetchRaidState();
      (this as any).processRaidData();
      await (this as any).getParticipatingCharacters();
      await (this as any).getParticipatingWeapons();
    };
    await refreshRaidData();
    interval = window.setInterval(async () => {
      await refreshRaidData();
    }, 3000);

    (this as any).$bvModal.show('rewardsModal');
    Events.$on('setActiveWeapon', (weapon: any) =>{
      this.selectedWeapon = weapon;
      this.selectedWeaponId = weapon.id;
    });
  },


  beforeDestroy() {
    clearInterval(interval);
  },

  components: {
    CurrencyConverter,
    WeaponInventory,
    NftIcon,
    NftList,
  },
});
</script>

<style scoped>

.raid-height {
  height: 500px !important;
}

.raid-style {
  display: block;
  width: 100%;
  padding: 0;
  height: 577px;
  overflow-y: auto;
  overflow-x: hidden;
  border: 0.5px solid #1f1f1f;
}

.progress-container {
  flex-direction: column;
}

.players-progress-bar {
  animation-direction: reverse;
}

.boss-progress-bar {
  animation-direction: normal;
}

.raid-style::-webkit-scrollbar-track
{
	-webkit-box-shadow: inset 0 0 6px rgba(156, 109, 46, 0.3);
	background-color: #F5F5F5;
}

.raid-style::-webkit-scrollbar
{
	width: 10px;
	background-color: #F5F5F5;
}
.raid-style::-webkit-scrollbar-thumb
{
	background-color: #a3773e;
	border: 2px solid #555555;
}

.raid-style >>> ul.character-list {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
}
.raid-style >>> ul.character-list > li.character {
    margin: 0 0 0 0;
    flex-grow: 0;
    flex-shrink: 0;
}

.raid-style >>> ul.character-list > li.character.selected {
    box-shadow: 0 3px 15px #ffd400;
    border: 0.5px solid #fff;
}

.raid-weapon-grid >>> .stars-elem  {
  width: 50% !important;
  max-width: 100% !important;
  flex: 0 0 50% !important;
}

.raid-weapon-grid >>> .clear-filters-button {
  max-width: 300px;
  width: 100%;
  margin-top: 10px;
  margin-left: 0px;
}

.raid-weapon-grid >>> .clear-filters-button > span {
  margin: 0 auto;
}

.raid-weapon-grid {
  height: 577px;
  overflow-y: auto;
  border: 0.5px solid #1f1f1f;
}

.raid-weapon-grid::-webkit-scrollbar-track
{
	-webkit-box-shadow: inset 0 0 6px rgba(156, 109, 46, 0.3);
	background-color: #F5F5F5;
}

.raid-weapon-grid::-webkit-scrollbar
{
	width: 10px;
	background-color: #F5F5F5;
}
.raid-weapon-grid::-webkit-scrollbar-thumb
{
	background-color: #a3773e;
	border: 2px solid #555555;
}


.raid-weapon-grid >>> .weapon-grid {
  width: 100% !important;
  margin: 0 auto;
  display: grid;
  justify-content: center;
  align-content: center;
  position: relative;
}

.raid-weapon-grid >>> ul.weapon-grid > li.weapon {
  margin: 0 auto;
  height: 100%;
  border-radius: 0;
  background-image: none;
  height: auto;
}
h2 {
  font-size: 20px;
}
h2 > span.sub-text {
  font-size: 16px;
  color: #fff;
  vertical-align: middle;
  line-height: 2;
}
hr.divider {
  border: 0.5px solid #dabf75;
}
.container-fluid {
  margin-top: 500px;
}
.list-group {
  max-width: 100%;
  border: 0;
  background: none;
}

.outline-box{
  display: flex;
  align-items: center;
  opacity: 0.5;
}

.outline-box > div:nth-child(1){
  height: 70px;
  width: 70px;
  display: flex;
  justify-content: center;
  align-items: center;
  border: #ccae4f dashed 2px;
  border-radius: 5px;
}

.outline-box > div:nth-child(2) {
  padding-left: 20px;
}

.weapon-info{
  margin-top: 10px;
}

.outline-box > div > p{
  margin: 0px;
  font-size: 15px;
  font-family: Roboto;
}

.outline-box > div > span{
  margin: 0px;
  font-size: 13px;
  font-family: Roboto;
}

.outline-box > div > div {
  cursor: pointer;
}


.outline-box > div > div > img{
  width: 30px;
}

.boss-list > img{
  animation-name: easeLeft;
  animation-duration: 1.5s;
}


@keyframes easeLeft {
  0%   {
    margin-left: 100px;
    opacity: 0;
  }
  100%  {
    margin-left: 0px;
    opacity: 1;
  }
}

.boss-details{
  animation-name: easeUp;
  animation-duration: 1.5s;
}

@keyframes easeUp {
  0%   {
    margin-top: 100px;
    opacity: 0;
  }
  100%  {
    margin-top: 0px;
    opacity: 1;
  }
}

.list-group-item {
  border-top: 0px !important;
  border-left: 0px !important;
  border-right: 0px !important;
  border-bottom: 0.5px solid #242423 !important;
}

.you-earned-raid{
  margin-bottom: 10px;
}

.results-panel > div > div {
    margin-bottom: 20px;
}

.you-earned-raid > h4{
  text-align: center;
  font-size: 1.3em;
  color: #fff;
  font-family: 'Roboto', 'serif'  !important;
}

.power-rolled .win-details:nth-child(1) {
    text-align: right;
}

.power-rolled .win-details > h5{
    color: #fff !important;
}



.body {
  display: flex;
  flex-direction: row;
  align-items: center;
  height: calc(100vh - 56px - 160px - 32px);
}
.raid-info-box {
  background: #2e2e30cc;
  padding: 20px;
  margin-bottom: 20px;
  border-radius: 0px;
  border: 1px solid #515152cc;
}
.border-box {
  border: 0.5px solid #242423;
  border-radius: 5px;
  padding: 10px 20px;
}
.raid-header {
  border-bottom: 0.5px dashed rgb(49, 45, 40);
  margin-bottom: 20px;
}
.boss-row {
  margin-bottom: -3px;
}
.boss-img {
  width: 100%;
  height: 100%;
  max-height: 413px;
  text-align: center;
}
.boss-img > img {
  width: 100%;
  height: 100%;
  max-height: 413px;
  max-width: 370px;
  object-fit: contain;
}
.boss-box {
  border: 0.5px solid #242423;
  border-radius: 5px;
  padding: 10px 20px;
  background: #ccc;
  background: url('../assets/background/video-bg.png');
  background-repeat: no-repeat;
  background-position: center;
}
.title {
  font-weight: bold;
  font-size: 1.4em;
}

.fill-space {
  height: 100%;
  padding: 1em;
  padding-top: 3em;
}

.left-side,
.right-side {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chooser,
.power {
  flex: 1;
  display: flex;
  flex-direction: row;
}

.chooser .left-side,
.chooser .right-side {
  max-height: 300px;
  overflow-y: auto;
}

.raid-info {
  flex-direction: row;
}

.raid-summary-text {
    width: auto;
    flex: none;
}

.raid-summary-container {
    flex-wrap: wrap;
    justify-content: space-between;
}

.raiders,
.drops {
  margin-top: 1em;
}

.drops-icons {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  width: 100%;
  padding: 0;
  overflow-y: hidden;
  overflow-x: hidden;
  /* border: 0.5px solid #1f1f1f; */
  /* height: 161px; */
}

.drops-icons >>> ul {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}


.btn-raid {
  display: flex;
  flex-direction: column;
  height: 100%;
  align-items: center;
  vertical-align: middle;
  justify-content: center;
  background-image: url('../assets/buttonOutline.svg');
  background-color: transparent;
  background-repeat: no-repeat;
  background-size: 100% 100%;
  object-fit: fill;
  padding: 20px 40px 20px 40px;
  border: none;
  font-family: Oswald;
  color: #fff;
  font-size: 20px;
}

.art{
  height: 70px;
  width: 70px;
  border-radius: 5px;
  border: 1px solid #fff;
  background-position: inherit;
  background-position-x: -20px;
  background-position-y: 10px;
  background-size: 150%;
  background-repeat: no-repeat;
}

.btn-raid > span{
  font-size: 13px;
  font-family: Roboto;
  color:#a3773e;
}

.join-raid{
  display: flex;
  margin-top: 50px;
  align-items: center;
}

.join-raid > div > span{
  text-transform: capitalize;
}

.join-raid > div{
  margin-left: 20px;
}

.join-raid > div > p{
  font-size: 17px;
  font-family: Roboto;
  margin: 0px;
}

.join-raid > div > span{
  font-size: 14px;
  font-family: Roboto;
  color: #fff;
  padding-left: 10px;
  padding-right: 10px;
}

.join-raid > div > span:nth-child(1){
  padding-left: 0px !important;
}



.drops-icons::-webkit-scrollbar-track
{
	-webkit-box-shadow: inset 0 0 6px rgba(156, 109, 46, 0.3);
	background-color: #F5F5F5;
}

.drops-icons::-webkit-scrollbar
{
	width: 10px;
	background-color: #F5F5F5;
}
.drops-icons::-webkit-scrollbar-thumb
{
	background-color: #a3773e;
	border: 2px solid #555555;
}


.encounter-button {
  display: block;
  top:0 !important;
}
.raid-boss,
.raid-signup {
  justify-content: space-between;
}

.warning,
.power,
.total-power,
.action {
  text-align: center;
  margin-top: 0.5em;
}

.encounter-button {
  display: block;
  margin: 2px auto;
  height: 5em;
  width: 20em;
  position: relative;
  top: 3vw;
}

.weapon-icon-wrapper {
  background: rgba(255, 255, 255, 0.1);
  width: 12em;
  height: 12em;
  margin: 0 auto;
}

.new-weapon-button {
  margin-left: 0;
  margin-top: 20px;
}

.enemy-list[data-v-067077ae] {
    display: flex;
    flex-wrap: wrap;
    padding-left: 30px;
    padding-right: 30px;
}

.raid-picker {
  display: flex;
  align-items: center;
}

.xp-reward-section {
  display: inline;
}

.rewards-tooltip {
  margin: auto 0;
}

.raid-title-section {
  font-size : 1.5em;
  color : #dabf75;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.raid-details {
  border: 1px solid;
  border-radius: 5px;
}

.raid-details-text {
  font-size: 1.2em;
  color: #ccae4f;
}

.raid-details-text > span {
  background-color: #5c6063;
}
.form-control.raid-id-selector {
  width: fit-content;
  height: fit-content;
  margin: 5px;
  padding: 0;
}

.xp-reward {
  background: #40422f;
  border: 1px solid #727151;
  padding: 4px;
  border-radius: 25%;
}

.trait-icon {
  transform: scale(1.5);
  margin-left: -10px;
}

.header-row {
  display: flex;
  align-items: center;
}

.header-row h1 {
  margin-left: 10px;
  margin-bottom: 5px;
}

.header-row .hint {
  font-size: 2em;
}

.header-row {
  display: block;
  text-align: center;
}

.boss-details > div{
  display: flex;
}

@font-face {
    font-family: 'Trajan';
    src: url('../assets/fonts/Trajan.ttf');
    font-weight: normal;
    font-style: normal;
}

#raid-header{
  overflow: hidden;
}

#raid-header > div:nth-child(1){
  background-image: url('../assets/bg_raid.png') ;
}


.boss-details > div > div >h3{
  font-family: Trajan;
}

.boss-list{
  position: absolute;
  gap: 20px;
}

.boss-list > div{
  margin-bottom: 20px;
}

.boss-list > img{
  width: 350px;
}

.boss-name > div > span{
  font-family: 'Roboto', 'serif';
  color: #fff;
  font-size: 13px;
}

.boss-details > div > span{
  margin-right: 20px;
}

.boss-details{
  padding-top: 40px;
  padding-bottom: 85px;
}

/* .raid-power{
} */

.raid-power > div:nth-child(1){
  border-right: 1px solid rgba(255, 255, 255, 0.138);
}



.nav-raid {
  margin-top: -60px;
  display: flex;
  background-color: rgba(0, 0, 0, 0.289);
}

.powers{
  padding-top: 40px;
}

.powers, .nav-raid, .drops, .join-raid{
  padding-left: 50px;
}

.nav-raid > div {
  margin-right: 20px;
  padding: 20px 30px;
}

.nav-raid > div:nth-child(1) {
  border-bottom: 3px solid #ccae4f;
}

.nav-raid > div > p{
  font-family: 'Oswald', sans-serif;
  color: #fff;
  font-size: 19px;
  margin: 0px;
}

.boss-details > div{
  margin-bottom: 20px;
}

.boss-name > div >span:nth-child(1){
  text-transform: capitalize;
}

.boss-name > div >span:nth-child(2){
  text-transform: capitalize;
}

.boss-list > div > img{
  width: 40%;
}

@font-face {
  font-family: 'Trajan';
  src: url('../assets/fonts/Trajan.ttf');
  font-weight: normal;
  font-style: normal;
}

.char-info{
  display: flex;
  flex-wrap: nowrap;
  margin-top: 10px;
}

.char-info .character-name{
  font-family: Trajan;
  color: #fff;
  margin: 0px;
}

.char-icon{
  margin-left: 1px;
  font-size: 13px;
   /* margin-top: 10px; */
}

.char-info > div:nth-child(2){
  margin-left: 20px;
}

.char-info > div:nth-child(2) > span > p{
  margin: 0px;
  font-family: Roboto;
}

.char-info > div:nth-child(2) > span > span{
  font-family: Roboto;
}


.weapon-info{
  display: flex;
  justify-content: space-between;
}

.weapon-info > div > p{
  color: #fff;
  margin: 0px;
}

.weapon-info > div > span{
  /* color: #fff; */
}


.weapon-info > div > img{
  width: 30px;
  cursor: pointer;
}

.weapon-info > div > img:hover{
  margin-top: -10px;
}

@import url('https://fonts.googleapis.com/css2?family=Oswald:wght@200;300;400;500;600;700&display=swap');

.powers{
  display: flex;
}

.powers > div{
  padding-right: 40px;
  padding-left: 40px;
}

.powers > div:nth-child(1){
  padding-left: 0px;
}

.powers > div:nth-child(1), .powers > div:nth-child(2), .powers > div:nth-child(3){
  border-right: 1px solid rgba(255, 255, 255, 0.433);
}

.powers > div > p{
  font-family: 'Oswald', sans-serif;
  color: #fff;
  font-size: 25px;
}

.powers > div > span{
  font-family: 'Roboto', sans-serif;
  font-size: 15px;
}

.drops > span{
  font-family: Roboto;
}


.boss-history{
  font-family: 'Roboto', 'serif';
  font-size: 13px;
}

@media (max-width: 600px) {
  .float-center .container .power-rolled {
    padding: 0px !important;
    width: 50% !important;
  }

  .win-details > .ins{
    width: 60%;
    margin: auto;
  }

  .results-panel > div > div {
    margin-bottom: 20px;
  }

  .powers > div > span{
    font-size: 2vw;
  }
}

@media (max-width: 994px) {

  img.img-responsive {
    height: 350px;
  }
}
@media (max-width: 726px) {
  .weap-box, .char-box {
    margin-top: 30px;
  }
  .img-responsive .boss-img {
    height: 300px;
  }
  .finish {
    text-align: center;
    margin: 10px;
  }
}

@media (max-width: 1200px) {
  .boss-col {
    display: block;
  }

  .powers > div > span{
    font-size: 1.1vw;
  }
}


@media (max-width: 1251px) {
  .boss-col {
    display: block;
  }
}
</style>
