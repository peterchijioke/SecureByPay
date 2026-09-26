import jwt from 'jsonwebtoken';
import { config } from '../config';

export interface TokenPayload {
  userId: string;
  email: string;
  role?: string;
}

const tokenBlacklist = new Set<string>();

export function generateToken(payload: TokenPayload): string {
  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn as jwt.SignOptions['expiresIn'],
  });
}

export function verifyToken(token: string): TokenPayload {
  if (tokenBlacklist.has(token)) {
    throw new Error('Token has been revoked/logged out.');
  }
  return jwt.verify(token, config.jwtSecret) as TokenPayload;
}

export function revokeToken(token: string): void {
  tokenBlacklist.add(token);
}

export function isTokenRevoked(token: string): boolean {
  return tokenBlacklist.has(token);
}

