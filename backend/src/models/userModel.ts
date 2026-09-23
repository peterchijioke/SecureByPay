export interface IUser {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  passwordHash: string;
  createdAt: string;
  walletBalance: number;
}

export type SafeUser = Omit<IUser, 'passwordHash'>;
