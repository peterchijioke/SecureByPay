import { Response, NextFunction } from 'express';
import { ShipmentService } from '../services/shipmentService';
import { AuthenticatedRequest } from '../middleware/authMiddleware';

export class ShipmentsController {
  static getShipments(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const userId = req.user?.userId;
      const shipments = ShipmentService.getShipments(userId);
      res.status(200).json({
        success: true,
        data: shipments,
      });
    } catch (error: any) {
      next(error);
    }
  }

  static getShipmentById(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const id = req.params.id as string;
      const shipment = ShipmentService.getShipmentById(id);
      if (!shipment) {
        res.status(404).json({ success: false, message: 'Shipment not found.' });
        return;
      }
      res.status(200).json({
        success: true,
        data: shipment,
      });
    } catch (error: any) {
      next(error);
    }
  }

  static payShipment(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const id = req.params.id as string;
      const updated = ShipmentService.payShipment(id);
      res.status(200).json({
        success: true,
        message: 'Shipment payment successful.',
        data: updated,
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Payment processing failed.',
      });
    }
  }
}
