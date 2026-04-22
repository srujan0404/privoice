import { Router } from 'express';
import { asyncHandler } from '../utils/asyncHandler.js';
import { requireAuth } from '../middleware/auth.js';
import { validateBody, validateQuery } from '../middleware/validate.js';
import { userLimiter } from '../middleware/rateLimit.js';
import { SyncPostSchema, SyncQuerySchema } from '../schemas/sync.schema.js';
import { pullSince, pushBatch } from '../services/sync.service.js';

export const syncRouter = Router();

const syncLimit = userLimiter(600, 60_000);

syncRouter.get(
  '/sync',
  requireAuth,
  syncLimit,
  validateQuery(SyncQuerySchema),
  asyncHandler(async (req, res) => {
    const result = await pullSince(req.user.id, req.query.since);
    res.json(result);
  }),
);

syncRouter.post(
  '/sync',
  requireAuth,
  syncLimit,
  validateBody(SyncPostSchema),
  asyncHandler(async (req, res) => {
    const result = await pushBatch(req.user.id, req.body);
    res.json({ ...result, serverTime: new Date().toISOString() });
  }),
);
