/**
 * Base error class. Any thrown AppError is converted to a JSON error response
 * by errorHandler middleware.
 */
export class AppError extends Error {
  /**
   * @param {string} code - machine-readable code, e.g. "AUTH_INVALID_CREDENTIALS"
   * @param {string} message - human-readable message for the client
   * @param {number} status - HTTP status
   * @param {unknown} [details] - optional structured detail payload
   */
  constructor(code, message, status, details = undefined) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export class ValidationError extends AppError {
  constructor(details) {
    super('VALIDATION_FAILED', 'Request validation failed.', 400, details);
    this.name = 'ValidationError';
  }
}

export class AuthError extends AppError {
  constructor(code, message, status = 401) {
    super(code, message, status);
    this.name = 'AuthError';
  }
}

export class NotFoundError extends AppError {
  /**
   * @param {string} [code='NOT_FOUND'] - machine-readable, e.g. 'USER_NOT_FOUND', 'NOTE_NOT_FOUND'
   * @param {string} [message='Not found.'] - human-readable
   */
  constructor(code = 'NOT_FOUND', message = 'Not found.') {
    super(code, message, 404);
    this.name = 'NotFoundError';
  }
}
