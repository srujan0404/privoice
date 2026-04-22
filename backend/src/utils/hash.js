import { createHash, randomBytes } from 'node:crypto';

/**
 * SHA-256 hex digest of a string.
 * Used for refresh-token storage and polish cache keys.
 * @param {string} input
 * @returns {string}
 */
export function sha256Hex(input) {
  return createHash('sha256').update(input).digest('hex');
}

/**
 * URL-safe random token (base64url). Default 32 bytes → 43-char string.
 * @param {number} [bytes=32]
 * @returns {string}
 */
export function randomToken(bytes = 32) {
  return randomBytes(bytes).toString('base64url');
}
