import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { requestLogger } from './middleware/requestLogger.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import { syncRouter } from './routes/sync.routes.js';
import { authRouter } from './routes/auth.routes.js';
import { userRouter } from './routes/user.routes.js';
import { polishRouter } from './routes/polish.routes.js';

export function createApp() {
  const app = express();

  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(cors());
  app.use(express.json({ limit: '2mb' }));
  app.use(requestLogger);

  app.get('/health', (_req, res) => {
    res.json({ ok: true });
  });

  app.use('/auth', authRouter);
  app.use('/', userRouter);
  app.use('/', syncRouter);
  app.use('/', polishRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
