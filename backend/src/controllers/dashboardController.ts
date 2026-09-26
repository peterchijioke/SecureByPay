import { Response, NextFunction } from 'express';
import { DashboardService } from '../services/dashboardService';
import { AuthService } from '../services/authService';
import { AuthenticatedRequest } from '../middleware/authMiddleware';
import { fundWalletSchema, formatZodErrors } from '../validators/authValidator';
import type {
  ApiResponse,
  OverviewResponseDto,
  GrowthResponseDto,
  FundWalletResponseDto,
} from '../dto';

export class DashboardController {
  static getOverview(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const userId = req.user?.userId;
      const data = DashboardService.getOverview(userId);
      const body: ApiResponse<OverviewResponseDto> = { success: true, data };
      res.status(200).json(body);
    } catch (error: any) {
      next(error);
    }
  }

  static getGrowth(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const periodRaw = req.query.period as string | undefined;
      const validPeriods = ['year', 'month', 'week'] as const;
      const period: 'year' | 'month' | 'week' = validPeriods.includes(periodRaw as any)
        ? (periodRaw as 'year' | 'month' | 'week')
        : 'year';

      const data = DashboardService.getGrowth(period);
      const body: ApiResponse<GrowthResponseDto> = {
        success: true,
        data: data as GrowthResponseDto,
      };
      res.status(200).json(body);
    } catch (error: any) {
      next(error);
    }
  }

  static fundWallet(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        const body: ApiResponse = { success: false, message: 'Unauthorized' };
        res.status(401).json(body);
        return;
      }

      // Coerce amount to number before parsing (body may send it as a string)
      const rawBody = { amount: Number(req.body.amount) };
      const parsed = fundWalletSchema.safeParse(rawBody);
      if (!parsed.success) {
        const errors = formatZodErrors(parsed.error);
        const body: ApiResponse = { success: false, message: errors[0], errors };
        res.status(400).json(body);
        return;
      }

      const newBalance = AuthService.updateWallet(userId, parsed.data.amount);
      const body: ApiResponse<FundWalletResponseDto> = {
        success: true,
        message: 'Wallet funded successfully.',
        data: { newBalance },
      };
      res.status(200).json(body);
    } catch (error: any) {
      next(error);
    }
  }
}
