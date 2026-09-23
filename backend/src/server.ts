import app from './app';
import { config } from './config';

const PORT = config.port;

app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(` SecureByPay Backend Server running on port ${PORT}`);
  console.log(` Health check: http://localhost:${PORT}/api/v1/health`);
  console.log(` Environment: ${config.nodeEnv}`);
  console.log(`===============================================`);
});
