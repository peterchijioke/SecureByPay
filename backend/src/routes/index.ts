import { Router } from 'express';
import authRoutes from './authRoutes';
import dashboardRoutes from './dashboardRoutes';
import shipmentRoutes from './shipmentRoutes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/shipments', shipmentRoutes);

router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'SecureByPay API',
    timestamp: new Date().toISOString(),
  });
});

export default router;
