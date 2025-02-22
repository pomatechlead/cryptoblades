<template>
  <div class="container">
    <span class="stake-header">
      <b-icon-exclamation-circle scale="0.8"
      :class="exclamationMark"
      v-tooltip="rewardTooltip"/>
      <div class="stake-icon-wrapper">
        <img src="https://seiyria.com/gameicons-font/svg/two-coins.svg" alt="" class="stake-type-icon">
      </div>
    </span>
    <h1 class="stake-type-title">{{ stakeTitle }}</h1>
    <div class="table-wrapper">
      <table class="stake-data-table">
        <tr>
          <th class="bold">
            {{$t('stake.stake')}}
          </th>
          <td class="align-right">
            {{ stakeTokenName }}
          </td>
        </tr>
        <tr>
          <th class="bold">
            {{$t('stake.StakeSelectorItem.earn')}}
          </th>
          <td class="align-right">
            {{ rewardTokenName }}
          </td>
        </tr>
        <tr v-if="estimatedYield" :title="$t('stake.StakeSelectorItem.yieldTooltip')">
          <th class="bold">
            {{ isNftStaking ? $t('stake.StakeSelectorItem.yield') : $t('stake.StakeSelectorItem.apy') }}
            <b-icon-question-circle v-if="isNftStaking" v-tooltip="$t('stake.StakeSelectorItem.yieldTooltip')"/>
          </th>
          <td class="align-right">
            {{ isNftStaking ? estimatedYield.toFixed(2) : estimatedYield.multipliedBy(100).toFixed(2) }}
            {{ isNftStaking ? '/NFT' : '%' }}
          </td>
        </tr>
        <tr v-if="minimumStakeTime !== 0">
          <th class="bold">
            {{$t('stake.StakeSelectorItem.stakeLocked')}}
          </th>
          <td class="align-right">
            {{ minimumStakeTimeFormatted }}
          </td>
        </tr>
        <tr v-if="rewardsDuration !== 0">
          <th class="bold">
            {{$t('stake.StakeSelectorItem.rewardsDuration')}}
          </th>
          <td class="align-right">
            {{ rewardsDurationFormatted }}
          </td>
        </tr>
      </table>
    </div>
    <router-link
      class="stake-select-button button dark-bg-text"
      :class="{ deprecated: deprecated }"
      :to="{ name: 'stake', params: { stakeType } }">
        <span v-if="deprecated">{{$t('stake.StakeSelectorItem.warning')}}</span>
        <span v-if="!deprecated">{{$t('stake.StakeSelectorItem.select')}}</span>
        <b-icon-question-circle-fill v-if="deprecated"
          v-tooltip="$t('stake.StakeSelectorItem.deprecatedTooltip')" />
    </router-link>
  </div>
</template>

<script>
import { formatDurationFromSeconds } from '../utils/date-time';
import { isNftStakeType } from '../interfaces/State';

export default {
  props: [
    'stakeTitle',
    'stakeTokenName',
    'rewardTokenName',
    'stakeType',
    'minimumStakeTime',
    'estimatedYield',
    'rewardsDuration',
    'deprecated',
    'rewardDistributionTimeLeft',
    'currentRewardEarned'
  ],
  computed: {
    minimumStakeTimeFormatted() {
      return formatDurationFromSeconds(this.minimumStakeTime);
    },
    isNftStaking() {
      return isNftStakeType(this.stakeType);
    },
    rewardsDurationFormatted() {
      return formatDurationFromSeconds(this.rewardsDuration);
    },
    exclamationMark() {
      let exclamationMark = '';

      if (this.rewardDistributionTimeLeft > 0) {
        exclamationMark += 'green-exclamation-mark ';
      } else {
        exclamationMark += 'red-exclamation-mark ';
      }

      if (this.currentRewardEarned > 0) {
        exclamationMark += 'gold-background';
      }
      return exclamationMark;
    },
    rewardTooltip() {
      if(this.rewardDistributionTimeLeft > 0) {
        if (this.currentRewardEarned > 0) {
          return this.$t('stake.StakeSelectorItem.rewardsAvailableEarnedTooltip');
        }
        return this.$t('stake.StakeSelectorItem.rewardsAvailableTooltip');
      }
      if (this.currentRewardEarned > 0) {
        return this.$t('stake.StakeSelectorItem.rewardsDepletedEarnedTooltip');
      }
      return this.$t('stake.StakeSelectorItem.rewardsDepletedTooltip');
    },
  },
};
</script>

<style scoped>
.container {
  background: rgb(22, 22, 22);
  background: linear-gradient(180deg, rgba(22, 22, 22, 1) 0%, rgba(16, 17, 17, 1) 100%);
  padding: 1rem;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stake-icon-wrapper {
  width: 5rem;
  height: 5rem;
  padding: 0.5rem;
  margin-left: auto;
  margin-right: auto;
}

.stake-type-icon {
  width: 100%;
  height: 100%;
  filter: invert(100%);
}

.stake-type-title {
  font-size: 1.2rem;
  padding-bottom: 5px;
  border-bottom: 1px solid #6c5f38;
}

.table-wrapper {
  width: 100%;
  flex-grow: 1;
}

.stake-data-table {
  width: 100%;
  padding: 1rem 0;
}

.align-right {
  text-align: right;
  color: #fff;
}

.stake-select-button {
  height: 3rem;
  width: 8rem;
  text-decoration: none;
  font-size: 1.5rem;
  display: flex;
  justify-content: center;
  align-items: center;
  border: 2px solid #6c5f38;
  border-radius: 0.1em;
  background: rgb(31, 31, 34);
  background: linear-gradient(180deg, rgba(31, 31, 34, 1) 0%, rgba(24, 27, 30, 1) 5%, rgba(24, 38, 45, 1) 100%);
  text-transform: uppercase;
  color: #9e8a57 !important;
}

.stake-select-button.deprecated {
  background: rgb(100, 50, 50);
}

.button:hover:not(:disabled) {
  background-color: rgba(255, 255, 255, 0.1);
  border-color: currentColor;
  cursor: pointer;
}

.green-exclamation-mark {
  float: right;
  color: rgb(41, 107, 28);
}

.red-exclamation-mark {
  float: right;
  color: rgb(153, 29, 29);
}

.gold-background {
  background: #9e8a57;
  border-radius: 50%;
}

.stake-header {
  width: 100%;
  font-size : 1.9em;
}
</style>
