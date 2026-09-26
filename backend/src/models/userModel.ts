export type UserRole = 'user' | 'admin';

export interface IUser {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  passwordHash: string;
  role: UserRole;
  createdAt: string;
  walletBalance: number;
}

export type SafeUser = Omit<IUser, 'passwordHash'>;

