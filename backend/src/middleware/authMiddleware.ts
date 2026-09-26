import { Request, Response, NextFunction } from 'express';
import { verifyToken, TokenPayload } from '../utils/jwt';

export interface AuthenticatedRequest extends Request {
  user?: TokenPayload;
  token?: string;
}

/**
 * Authentication Middleware:
 * Verifies JWT token from Authorization header and attaches payload to req.user.
 */
export function authenticate(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({
      success: false,
      message: 'Authentication required. No Bearer token provided.',
    });
    return;
  }

  const token = authHeader.split(' ')[1];
  try {
    const payload = verifyToken(token);
    req.user = payload;
    req.token = token;
    next();
  } catch (error: any) {
    res.status(401).json({
      success: false,
      message: error?.message || 'Invalid or expired token.',
    });
  }
}

/**
 * Authorization Middleware (RBAC):
 * Ensures the authenticated user has one of the required roles.
 */
export function authorize(...roles: string[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required.',
      });
      return;
    }

    const userRole = req.user.role || 'user';
    if (roles.length > 0 && !roles.includes(userRole)) {
      res.status(403).json({
        success: false,
        message: `Forbidden: role '${userRole}' is not authorized to access this resource.`,
      });
      return;
    }

    next();
  };
}

