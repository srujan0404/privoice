import 'dotenv/config';
import { env } from './config/env.js';
import { connectDb, disconnectDb } from './config/db.js';
import { createApp } from './app.js';
import { logger } from './utils/logger.js';

const SHUTDOWN_GRACE_MS = 10_000;

async function main() {
  await connectDb();
  const app = createApp();
  const server = app.listen(env.PORT, () => {
    logger.info({ port: env.PORT, env: env.NODE_ENV }, 'server listening');
  });

  let shuttingDown = false;
  const shutdown = (signal) => {
    if (shuttingDown) {
      logger.warn({ signal }, 'second shutdown signal — forcing exit');
      process.exit(1);
    }
    shuttingDown = true;
    logger.info({ signal }, 'shutting down');

    const forceExit = setTimeout(() => {
      logger.warn({ graceMs: SHUTDOWN_GRACE_MS }, 'shutdown timed out — forcing exit');
      process.exit(1);
    }, SHUTDOWN_GRACE_MS);
    forceExit.unref();

    server.close(async () => {
      logger.info('http server closed');
      try {
        await disconnectDb();
      } catch (err) {
        logger.error({ err }, 'mongo disconnect failed');
      }
      clearTimeout(forceExit);
      process.exit(0);
    });
  };
  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

process.on('unhandledRejection', (reason) => {
  logger.fatal({ err: reason }, 'unhandled rejection');
  process.exit(1);
});
process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'uncaught exception');
  process.exit(1);
});

main().catch((err) => {
  logger.fatal({ err }, 'fatal boot error');
  process.exit(1);
});
