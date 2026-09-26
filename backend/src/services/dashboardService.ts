import { AuthService } from './authService';

export interface OverviewMetrics {
  balance: number;
  currency: string;
  totalShipments: {
    count: number;
    growthPercentage: number;
    vsLastMonth: number;
  };
  totalExports: {
    count: number;
    growthPercentage: number;
    vsLastMonth: number;
  };
  totalImports: {
    count: number;
    growthPercentage: number;
    vsLastMonth: number;
  };
}

export interface GrowthDataPoint {
  label: string;
  value: number;
}

export class DashboardService {
  static getOverview(userId?: string): OverviewMetrics {
    let balance = 3000000.28;
    if (userId) {
      const user = AuthService.getUserById(userId);
      if (user) balance = user.walletBalance;
    }

    return {
      balance,
      currency: 'NGN',
      totalShipments: {
        count: 34,
        growthPercentage: 90,
        vsLastMonth: 4,
      },
      totalExports: {
        count: 34,
        growthPercentage: 90,
        vsLastMonth: 4,
      },
      totalImports: {
        count: 34,
        growthPercentage: 90,
        vsLastMonth: 4,
      },
    };
  }

  static getGrowth(period: 'year' | 'month' | 'week' = 'year'): { period: string; points: GrowthDataPoint[] } {
    if (period === 'week') {
      return {
        period: 'week',
        points: [
          { label: 'Mon', value: 340 },
          { label: 'Tue', value: 480 },
          { label: 'Wed', value: 390 },
          { label: 'Thu', value: 520 },
          { label: 'Fri', value: 680 },
          { label: 'Sat', value: 590 },
          { label: 'Sun', value: 850 },
        ],
      };
    }

    if (period === 'month') {
      return {
        period: 'month',
        points: [
          { label: 'W1', value: 310 },
          { label: 'W2', value: 460 },
          { label: 'W3', value: 580 },
          { label: 'W4', value: 920 },
        ],
      };
    }

    return {
      period: 'year',
      points: [
        { label: '1', value: 280 },
        { label: '2', value: 320 },
        { label: '3', value: 300 },
        { label: '4', value: 360 },
        { label: '5', value: 320 },
        { label: '6', value: 440 },
        { label: '7', value: 310 },
        { label: '8', value: 480 },
        { label: '9', value: 420 },
        { label: '10', value: 630 },
        { label: '11', value: 160 },
        { label: '12', value: 980 },
      ],
    };
  }
}
