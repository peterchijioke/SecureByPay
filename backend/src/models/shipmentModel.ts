export type ShipmentStatus = 'In-Transit' | 'Delayed' | 'Delivered' | 'Pending';
export type PaymentStatus = 'Paid' | 'Unpaid';

export interface IShipment {
  id: string;
  trackingId: string;
  sender: string;
  receiver: string;
  pickupLocation: string;
  pickupCountry: string;
  deliveryLocation: string;
  deliveryCountry: string;
  amount: number;
  currency: string;
  status: ShipmentStatus;
  paymentStatus: PaymentStatus;
  processingTimeHours: number;
  createdAt: string;
  userId: string;
}
