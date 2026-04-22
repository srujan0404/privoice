import { AuthError } from '../utils/errors.js';
import { verifyAccessToken } from '../services/token.service.js';

/**
 * Requires `Authorization: Bearer <jwt>`. Attaches `req.user = { id }` on success.
 * @type {import('express').RequestHandler}
 */
export function requireAuth(req, _res, next) {
  const header = req.header('authorization') || '';
  const match = header.match(/^Bearer (.+)$/i);
  if (!match) return next(new AuthError('AUTH_TOKEN_INVALID', 'Missing bearer token.'));

  try {
    const claims = verifyAccessToken(match[1]);
    req.user = { id: claims.sub };
    next();
  } catch {
    next(new AuthError('AUTH_TOKEN_INVALID', 'Access token is invalid or expired.'));
  }
}
