import { Router } from 'express';
import { DashboardController } from '../controllers/dashboardController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.get('/overview', authenticate as any, DashboardController.getOverview as any);
router.get('/growth', authenticate as any, DashboardController.getGrowth as any);
router.post('/wallet/fund', authenticate as any, DashboardController.fundWallet as any);

export default router;
