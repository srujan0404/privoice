import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { requestLogger } from './middleware/requestLogger.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';

export function createApp() {
  const app = express();

  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(cors());
  app.use(express.json({ limit: '2mb' }));
  app.use(requestLogger);

  app.get('/health', (_req, res) => {
    res.json({ ok: true });
  });

  // All routers will be registered below this line in later tasks.

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
