import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { sha256Hex, randomToken } from '../utils/hash.js';

/**
 * Parse a duration string like "15m", "60d", "3600s", or a bare number of ms.
 * Rejects zero or negative values (caller wants a positive TTL).
 * @param {string} spec
 * @returns {number} milliseconds, > 0
 */
function durationToMs(spec) {
  const s = String(spec).trim();
  if (/^\d+$/.test(s)) {
    const n = Number(s);
    if (n <= 0) throw new Error(`duration must be positive: ${spec}`);
    return n;
  }
  const m = s.match(/^(\d+)([smhd])$/);
  if (!m) throw new Error(`invalid duration: ${spec}`);
  const n = Number(m[1]);
  if (n <= 0) throw new Error(`duration must be positive: ${spec}`);
  const mult = { s: 1_000, m: 60_000, h: 3_600_000, d: 86_400_000 }[m[2]];
  return n * mult;
}

/**
 * Sign a short-lived access JWT for the given user id. Algorithm pinned to HS256.
 * @param {string} userId
 * @returns {string} JWT
 */
export function signAccessToken(userId) {
  return jwt.sign({ sub: userId, typ: 'access' }, env.JWT_ACCESS_SECRET, {
    algorithm: 'HS256',
    expiresIn: env.JWT_ACCESS_TTL,
  });
}

/**
 * Verify an access JWT. Algorithm is pinned to HS256 to prevent algorithm-confusion
 * attacks. Throws on signature failure, expiry, wrong typ, or malformed payload.
 * @param {string} token
 * @returns {{ sub: string, typ: 'access', iat: number, exp: number }}
 */
export function verifyAccessToken(token) {
  const claims = jwt.verify(token, env.JWT_ACCESS_SECRET, { algorithms: ['HS256'] });
  if (
    !claims ||
    typeof claims !== 'object' ||
    Array.isArray(claims) ||
    claims.typ !== 'access' ||
    typeof claims.sub !== 'string'
  ) {
    throw new Error('invalid token payload');
  }
  return /** @type {any} */ (claims);
}

/**
 * Generate a fresh opaque refresh token and its sha256 hash.
 * Caller persists `hash` in DB and returns `token` to the client.
 * @returns {{ token: string, hash: string, expiresAt: Date }}
 */
export function generateRefreshToken() {
  const token = randomToken(32);
  const hash = sha256Hex(token);
  const expiresAt = new Date(Date.now() + durationToMs(env.JWT_REFRESH_TTL));
  return { token, hash, expiresAt };
}

/**
 * Compute the stored hash for a raw refresh token.
 * @param {string} token
 * @returns {string}
 */
export function hashRefreshToken(token) {
  return sha256Hex(token);
}
