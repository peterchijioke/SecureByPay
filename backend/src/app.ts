import express from 'express';
import cors from 'cors';
import path from 'path';
import fs from 'fs';
import routes from './routes';
import { errorHandler } from './middleware/errorMiddleware';

const app = express();

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/v1', routes);

const serveFrontend = process.env.SERVE_FRONTEND === 'true';
const frontendBuildPath = path.join(__dirname, '../../frontend/build/web');

if (serveFrontend && fs.existsSync(frontendBuildPath)) {
  app.use(express.static(frontendBuildPath));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api')) {
      return next();
    }
    res.sendFile(path.join(frontendBuildPath, 'index.html'));
  });
} else {
  app.get('/', (req, res) => {
    res.json({
      service: 'SecureByPay Backend API',
      status: 'healthy',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      docs: {
        health: '/api/v1/health',
        auth: {
          register: 'POST /api/v1/auth/register',
          login: 'POST /api/v1/auth/login',
          me: 'GET /api/v1/auth/me',
        },
        shipments: {
          list: 'GET /api/v1/shipments',
          create: 'POST /api/v1/shipments',
          stats: 'GET /api/v1/shipments/stats',
        },
        dashboard: {
          overview: 'GET /api/v1/dashboard/overview',
        },
      },
    });
  });
}

app.use(errorHandler);

export default app;
