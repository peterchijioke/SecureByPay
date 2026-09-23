import { Response, NextFunction } from 'express';
import { DashboardService } from '../services/dashboardService';
import { AuthService } from '../services/authService';
import { AuthenticatedRequest } from '../middleware/authMiddleware';

export class DashboardController {
  static getOverview(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const userId = req.user?.userId;
      const data = DashboardService.getOverview(userId);
      res.status(200).json({
        success: true,
        data,
      });
    } catch (error: any) {
      next(error);
    }
  }

  static getGrowth(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const period = (req.query.period as 'year' | 'month' | 'week') || 'year';
      const data = DashboardService.getGrowth(period);
      res.status(200).json({
        success: true,
        data,
      });
    } catch (error: any) {
      next(error);
    }
  }

  static fundWallet(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const amount = parseFloat(req.body.amount || '50000');
      if (isNaN(amount) || amount <= 0) {
        res.status(400).json({ success: false, message: 'Invalid funding amount.' });
        return;
      }

      const newBalance = AuthService.updateWallet(userId, amount);
      res.status(200).json({
        success: true,
        message: 'Wallet funded successfully.',
        data: { newBalance },
      });
    } catch (error: any) {
      next(error);
    }
  }
}
