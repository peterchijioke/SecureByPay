import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../middleware/authMiddleware';
import { ShipmentService } from '../services/shipmentService';
import { shipmentsQuerySchema, shipmentIdSchema, formatZodErrors } from '../validators/shipmentValidator';
import type {
  ApiResponse,
  ShipmentResponseDto,
  ShipmentsListResponseDto,
  PayShipmentResponseDto,
} from '../dto';

export class ShipmentsController {
  static getShipments(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const parsed = shipmentsQuerySchema.safeParse(req.query);
      if (!parsed.success) {
        const errors = formatZodErrors(parsed.error);
        const body: ApiResponse = { success: false, message: errors[0], errors };
        res.status(400).json(body);
        return;
      }

      const userId = req.user?.userId;
      let shipments = ShipmentService.getShipments(userId);

      const { status, paymentStatus, limit, offset } = parsed.data;
      if (status) shipments = shipments.filter((s) => s.status === status);
      if (paymentStatus) shipments = shipments.filter((s) => s.paymentStatus === paymentStatus);
      const start = offset ?? 0;
      const end = limit !== undefined ? start + limit : undefined;
      shipments = shipments.slice(start, end);

      const body: ApiResponse<ShipmentResponseDto[]> = { success: true, data: shipments };
      res.status(200).json(body);
    } catch (error: any) {
      next(error);
    }
  }

  static getShipmentById(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const parsed = shipmentIdSchema.safeParse(req.params);
      if (!parsed.success) {
        const errors = formatZodErrors(parsed.error);
        const body: ApiResponse = { success: false, message: errors[0], errors };
        res.status(400).json(body);
        return;
      }

      const shipment = ShipmentService.getShipmentById(parsed.data.id);
      if (!shipment) {
        const body: ApiResponse = { success: false, message: 'Shipment not found.' };
        res.status(404).json(body);
        return;
      }

      const body: ApiResponse<ShipmentResponseDto> = { success: true, data: shipment };
      res.status(200).json(body);
    } catch (error: any) {
      next(error);
    }
  }

  static payShipment(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    try {
      const parsed = shipmentIdSchema.safeParse(req.params);
      if (!parsed.success) {
        const errors = formatZodErrors(parsed.error);
        const body: ApiResponse = { success: false, message: errors[0], errors };
        res.status(400).json(body);
        return;
      }

      const updated = ShipmentService.payShipment(parsed.data.id);
      const body: ApiResponse<PayShipmentResponseDto> = {
        success: true,
        message: 'Shipment payment successful.',
        data: { shipment: updated },
      };
      res.status(200).json(body);
    } catch (error: any) {
      const body: ApiResponse = {
        success: false,
        message: error.message || 'Payment processing failed.',
      };
      res.status(400).json(body);
    }
  }
}
