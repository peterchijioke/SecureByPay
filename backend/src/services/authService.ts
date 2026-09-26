import bcrypt from 'bcryptjs';
import fs from 'fs';
import path from 'path';
import { IUser, SafeUser, UserRole } from '../models/userModel';
import { generateToken, revokeToken } from '../utils/jwt';

const DB_FILE = path.join(__dirname, '../../data/users.json');

function ensureDbFile(): void {
  const dir = path.dirname(DB_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  if (!fs.existsSync(DB_FILE)) {
    const salt = bcrypt.genSaltSync(10);
    const defaultPasswordHash = bcrypt.hashSync('Password123!', salt);
    const initialUsers: IUser[] = [
      {
        id: 'usr-1',
        firstName: 'Bunmi',
        lastName: 'Tanny',
        email: 'user@example.com',
        phone: '+2348012345678',
        passwordHash: defaultPasswordHash,
        role: 'user',
        createdAt: new Date().toISOString(),
        walletBalance: 3000000.28,
      },
      {
        id: 'usr-admin',
        firstName: 'Admin',
        lastName: 'SecureByPay',
        email: 'admin@securebypay.com',
        phone: '+2348000000000',
        passwordHash: defaultPasswordHash,
        role: 'admin',
        createdAt: new Date().toISOString(),
        walletBalance: 10000000.0,
      },
    ];
    fs.writeFileSync(DB_FILE, JSON.stringify(initialUsers, null, 2), 'utf-8');
  }
}

function readUsers(): IUser[] {
  ensureDbFile();
  try {
    const data = fs.readFileSync(DB_FILE, 'utf-8');
    const users: IUser[] = JSON.parse(data);
    return users.map((u) => ({
      ...u,
      role: u.role || 'user',
    }));
  } catch {
    return [];
  }
}

function writeUsers(users: IUser[]): void {
  ensureDbFile();
  fs.writeFileSync(DB_FILE, JSON.stringify(users, null, 2), 'utf-8');
}

export function toSafeUser(user: IUser): SafeUser {
  const { passwordHash, ...safe } = user;
  return safe;
}

export class AuthService {
  static async register(data: {
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    password: string;
    role?: UserRole;
  }): Promise<{ user: SafeUser; token: string }> {
    const users = readUsers();
    const existing = users.find((u) => u.email.toLowerCase() === data.email.toLowerCase());
    if (existing) {
      throw new Error('A user with this email already exists.');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    const newUser: IUser = {
      id: `usr-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      firstName: data.firstName.trim(),
      lastName: data.lastName.trim(),
      email: data.email.toLowerCase().trim(),
      phone: data.phone.trim(),
      passwordHash,
      role: data.role || 'user',
      createdAt: new Date().toISOString(),
      walletBalance: 3000000.28,
    };

    users.push(newUser);
    writeUsers(users);

    const token = generateToken({
      userId: newUser.id,
      email: newUser.email,
      role: newUser.role,
    });
    return { user: toSafeUser(newUser), token };
  }

  static async login(data: {
    email: string;
    password: string;
  }): Promise<{ user: SafeUser; token: string }> {
    const users = readUsers();
    const user = users.find((u) => u.email.toLowerCase() === data.email.toLowerCase());
    if (!user) {
      throw new Error('Invalid email or password.');
    }

    const match = await bcrypt.compare(data.password, user.passwordHash);
    if (!match) {
      throw new Error('Invalid email or password.');
    }

    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role || 'user',
    });
    return { user: toSafeUser(user), token };
  }

  static getUserById(id: string): SafeUser | null {
    const users = readUsers();
    const user = users.find((u) => u.id === id);
    return user ? toSafeUser(user) : null;
  }

  static refreshToken(userId: string): { user: SafeUser; token: string } {
    const users = readUsers();
    const user = users.find((u) => u.id === userId);
    if (!user) {
      throw new Error('User not found.');
    }

    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role || 'user',
    });
    return { user: toSafeUser(user), token };
  }

  static logout(token: string): void {
    if (token) {
      revokeToken(token);
    }
  }

  static updateWallet(userId: string, amount: number): number {
    const users = readUsers();
    const user = users.find((u) => u.id === userId);
    if (!user) throw new Error('User not found.');
    user.walletBalance += amount;
    writeUsers(users);
    return user.walletBalance;
  }
}

