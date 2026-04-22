import { Router } from 'express';
import { asyncHandler } from '../utils/asyncHandler.js';
import { requireAuth } from '../middleware/auth.js';
import { validateBody } from '../middleware/validate.js';
import { userLimiter } from '../middleware/rateLimit.js';
import { PolishSchema } from '../schemas/polish.schema.js';
import { polish } from '../services/polish.service.js';

export const polishRouter = Router();

const polishLimit = userLimiter(60, 60_000);

polishRouter.post(
  '/polish',
  requireAuth,
  polishLimit,
  validateBody(PolishSchema),
  asyncHandler(async (req, res) => {
    const result = await polish(req.body);
    res.json(result);
  }),
);
