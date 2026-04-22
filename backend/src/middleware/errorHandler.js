import { AppError } from '../utils/errors.js';
import { logger } from '../utils/logger.js';

/**
 * Final express error-handling middleware. Maps thrown errors to the JSON envelope
 * `{ error: { code, message, details } }` and sets the matching HTTP status.
 * @type {import('express').ErrorRequestHandler}
 */
export function errorHandler(err, req, res, next) {
  // If a response is already streaming (e.g. SSE), defer to express' default handler —
  // writing a new body would throw ERR_HTTP_HEADERS_SENT and mask the original error.
  if (res.headersSent) return next(err);

  if (err instanceof AppError) {
    const level = err.status >= 500 ? 'error' : 'warn';
    logger[level](
      { err, path: req.path, method: req.method, code: err.code, status: err.status },
      'app error',
    );
    return res.status(err.status).json({
      error: { code: err.code, message: err.message, details: err.details ?? null },
    });
  }

  // body-parser: malformed JSON → 400
  if (err?.type === 'entity.parse.failed') {
    logger.warn({ path: req.path, method: req.method }, 'invalid json body');
    return res.status(400).json({
      error: { code: 'INVALID_JSON', message: 'Request body is not valid JSON.', details: null },
    });
  }

  // body-parser: body exceeded express.json limit → 413
  if (err?.type === 'entity.too.large') {
    logger.warn({ path: req.path, method: req.method, limit: err.limit }, 'payload too large');
    return res.status(413).json({
      error: { code: 'PAYLOAD_TOO_LARGE', message: 'Request body exceeds size limit.', details: null },
    });
  }

  // body-parser: unsupported content encoding/charset → 415
  if (err?.type === 'encoding.unsupported' || err?.type === 'charset.unsupported') {
    logger.warn({ path: req.path, method: req.method, type: err.type }, 'unsupported media type');
    return res.status(415).json({
      error: { code: 'UNSUPPORTED_MEDIA_TYPE', message: 'Unsupported content encoding.', details: null },
    });
  }

  logger.error({ err, path: req.path, method: req.method }, 'unhandled error');
  return res.status(500).json({
    error: { code: 'INTERNAL', message: 'Internal server error.', details: null },
  });
}

/** @type {import('express').RequestHandler} */
export function notFoundHandler(_req, res) {
  res.status(404).json({
    error: { code: 'NOT_FOUND', message: 'Route not found.', details: null },
  });
}
