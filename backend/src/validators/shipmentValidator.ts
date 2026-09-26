import { z } from 'zod';

export const shipmentIdSchema = z.object({
  id: z.string().min(1, 'Shipment ID must not be empty.').trim(),
});

export type ShipmentIdParams = z.infer<typeof shipmentIdSchema>;

export const shipmentsQuerySchema = z.object({
  status: z.enum(['In-Transit', 'Delayed', 'Delivered', 'Pending']).optional(),
  paymentStatus: z.enum(['Paid', 'Unpaid']).optional(),
  limit: z
    .string()
    .optional()
    .transform((v) => (v ? parseInt(v, 10) : undefined))
    .refine((v) => v === undefined || (!isNaN(v) && v > 0), {
      message: 'limit must be a positive integer.',
    }),
  offset: z
    .string()
    .optional()
    .transform((v) => (v ? parseInt(v, 10) : undefined))
    .refine((v) => v === undefined || (!isNaN(v) && v >= 0), {
      message: 'offset must be a non-negative integer.',
    }),
});

export type ShipmentsQuery = z.infer<typeof shipmentsQuerySchema>;

export function formatZodErrors(error: z.ZodError): string[] {
  return error.issues.map((e) => e.message);
}
