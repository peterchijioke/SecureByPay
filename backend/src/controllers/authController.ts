import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthService } from '../services/authService';
import { AuthenticatedRequest } from '../middleware/authMiddleware';
import { registerSchema, loginSchema, formatZodErrors } from '../validators/authValidator';
import type { ApiResponse, AuthResponseDto, UserResponseDto } from '../dto';

export class AuthController {
  static async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const parsed = registerSchema.safeParse(req.body);
      if (!parsed.success) {
        const errors = formatZodErrors(parsed.error);
        res.status(400).json({
          success: false,
          message: errors[0],
          errors,
        });
        return;
      }

      const { firstName, lastName, email, phone, password, role } = parsed.data;
      const result = await AuthService.register({ firstName, lastName, email, phone, password, role });
      res.status(201).json({
        success: true,
        message: 'Account created successfully.',
        data: result,
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Registration failed.',
      });
    }
  }

  static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const parsed = loginSchema.safeParse(req.body);
      if (!parsed.success) {
        const errors = formatZodErrors(parsed.error);
        res.status(400).json({
          success: false,
          message: errors[0],
          errors,
        });
        return;
      }

      const { email, password } = parsed.data;
      const result = await AuthService.login({ email, password });
      res.status(200).json({
        success: true,
        message: 'Logged in successfully.',
        data: result,
      });
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: error.message || 'Invalid credentials.',
      });
    }
  }

  static async getMe(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user?.userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const user = AuthService.getUserById(req.user.userId);
      if (!user) {
        res.status(404).json({ success: false, message: 'User not found.' });
        return;
      }

      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      next(error);
    }
  }

  static async refresh(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user?.userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const result = AuthService.refreshToken(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'Token refreshed successfully.',
        data: result,
      });
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: error.message || 'Token refresh failed.',
      });
    }
  }

  static async logout(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const token = req.token || req.headers.authorization?.split(' ')[1];
      if (token) {
        AuthService.logout(token);
      }
      res.status(200).json({
        success: true,
        message: 'Logged out successfully.',
      });
    } catch (error: any) {
      next(error);
    }
  }
}
