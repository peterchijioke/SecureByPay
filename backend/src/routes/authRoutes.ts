import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.get('/me', authenticate as any, AuthController.getMe as any);
router.post('/refresh', authenticate as any, AuthController.refresh as any);
router.post('/logout', authenticate as any, AuthController.logout as any);

export default router;

