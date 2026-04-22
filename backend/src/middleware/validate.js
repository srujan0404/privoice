import { ValidationError } from '../utils/errors.js';

/**
 * Build a middleware that validates req.body with a Zod schema and replaces it with the parsed value.
 * @param {import('zod').ZodTypeAny} schema
 * @returns {import('express').RequestHandler}
 */
export function validateBody(schema) {
  return (req, _res, next) => {
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
      const details = parsed.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message }));
      return next(new ValidationError(details));
    }
    req.body = parsed.data;
    next();
  };
}

/**
 * Build a middleware that validates req.query with a Zod schema.
 * @param {import('zod').ZodTypeAny} schema
 * @returns {import('express').RequestHandler}
 */
export function validateQuery(schema) {
  return (req, _res, next) => {
    const parsed = schema.safeParse(req.query);
    if (!parsed.success) {
      const details = parsed.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message }));
      return next(new ValidationError(details));
    }
    req.query = parsed.data;
    next();
  };
}
