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

// API versioning prefix
app.use('/api/v1', routes);

// Serve frontend web build if available
const frontendBuildPath = path.join(__dirname, '../../frontend/build/web');
if (fs.existsSync(frontendBuildPath)) {
  app.use(express.static(frontendBuildPath));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api')) {
      return next();
    }
    res.sendFile(path.join(frontendBuildPath, 'index.html'));
  });
} else {
  // Base route for quick test
  app.get('/', (req, res) => {
    res.json({
      message: 'Welcome to SecureByPay (Myafrimall) Backend API',
      version: '1.0.0',
      documentation: '/api/v1/health',
    });
  });
}

app.use(errorHandler);

export default app;
