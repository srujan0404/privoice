import rateLimit from 'express-rate-limit';

/**
 * Factory for an IP-based rate limiter. Used on public endpoints (auth).
 * @param {number} max - requests per window
 * @param {number} windowMs - window size in ms
 */
export function ipLimiter(max, windowMs) {
  return rateLimit({
    max,
    windowMs,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    message: { error: { code: 'RATE_LIMITED', message: 'Too many requests.', details: null } },
  });
}

/**
 * Factory for a user-based rate limiter. Falls back to IP when req.user is missing.
 * @param {number} max
 * @param {number} windowMs
 */
export function userLimiter(max, windowMs) {
  return rateLimit({
    max,
    windowMs,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    keyGenerator: (req) => req.user?.id ?? req.ip,
    message: { error: { code: 'RATE_LIMITED', message: 'Too many requests.', details: null } },
  });
}
