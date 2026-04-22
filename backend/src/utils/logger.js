import pino from 'pino';
import { env } from '../config/env.js';

export const logger = pino({
  level: env.LOG_LEVEL,
  base: undefined,
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: {
    paths: [
      'password',
      '*.password',
      'req.body.password',
      'req.body.currentPassword',
      'req.body.newPassword',
      'req.body.refreshToken',
      'req.headers.authorization',
      'req.headers.cookie',
      'res.headers["set-cookie"]',
      'authorization',
      '*.authorization',
      'refreshToken',
      '*.refreshToken',
      'accessToken',
      '*.accessToken',
      'token',
      '*.token',
    ],
    censor: '[REDACTED]',
  },
});
