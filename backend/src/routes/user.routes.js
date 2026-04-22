import { Router } from 'express';
import { asyncHandler } from '../utils/asyncHandler.js';
import { requireAuth } from '../middleware/auth.js';
import { validateBody } from '../middleware/validate.js';
import { UpdateMeSchema } from '../schemas/auth.schema.js';
import { getProfile, updateProfile } from '../services/user.service.js';

export const userRouter = Router();

userRouter.get(
  '/me',
  requireAuth,
  asyncHandler(async (req, res) => {
    const user = await getProfile(req.user.id);
    res.json(user);
  }),
);

userRouter.patch(
  '/me',
  requireAuth,
  validateBody(UpdateMeSchema),
  asyncHandler(async (req, res) => {
    const user = await updateProfile(req.user.id, req.body);
    res.json(user);
  }),
);
