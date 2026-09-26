export interface ApiResponse<T = void> {
  success: boolean;
  message?: string;
  errors?: string[];
  data?: T;
}

export interface RegisterRequestDto {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  password: string;
  role?: 'user' | 'admin';
}

export interface LoginRequestDto {
  email: string;
  password: string;
}

export interface UserResponseDto {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  role: 'user' | 'admin';
  walletBalance: number;
  currency: string;
  createdAt: string;
}

export interface AuthResponseDto {
  token: string;
  user: UserResponseDto;
}

export interface MeResponseDto {
  user: UserResponseDto;
}

export interface RefreshResponseDto {
  token: string;
  user: UserResponseDto;
}

export interface MetricBlockDto {
  count: number;
  growthPercentage: number;
  vsLastMonth: number;
}

export interface OverviewResponseDto {
  balance: number;
  currency: string;
  totalShipments: MetricBlockDto;
  totalExports: MetricBlockDto;
  totalImports: MetricBlockDto;
}

export interface GrowthPointDto {
  label: string;
  value: number;
}

export interface GrowthResponseDto {
  period: 'year' | 'month' | 'week';
  points: GrowthPointDto[];
}

export interface FundWalletRequestDto {
  amount: number;
}

export interface FundWalletResponseDto {
  newBalance: number;
}

export type ShipmentStatus = 'In-Transit' | 'Delayed' | 'Delivered' | 'Pending';
export type PaymentStatus = 'Paid' | 'Unpaid';

export interface ShipmentResponseDto {
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

export interface ShipmentsListResponseDto {
  shipments: ShipmentResponseDto[];
}

export interface PayShipmentResponseDto {
  shipment: ShipmentResponseDto;
}
