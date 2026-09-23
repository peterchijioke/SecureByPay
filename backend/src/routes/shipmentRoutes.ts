import { Router } from 'express';
import { ShipmentsController } from '../controllers/shipmentsController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticate as any, ShipmentsController.getShipments as any);
router.get('/:id', authenticate as any, ShipmentsController.getShipmentById as any);
router.post('/:id/pay', authenticate as any, ShipmentsController.payShipment as any);

export default router;
