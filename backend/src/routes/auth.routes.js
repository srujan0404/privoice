import { Router } from 'express';
import { asyncHandler } from '../utils/asyncHandler.js';
import { validateBody } from '../middleware/validate.js';
import { ipLimiter } from '../middleware/rateLimit.js';
import {
  RegisterSchema,
  LoginSchema,
  RefreshSchema,
  LogoutSchema,
  GoogleLoginSchema,
} from '../schemas/auth.schema.js';
import { register, login, refresh, logout, googleLogin } from '../services/auth.service.js';

export const authRouter = Router();

const loginLimit = ipLimiter(10, 60_000);
const refreshLimit = ipLimiter(30, 60_000);

authRouter.post(
  '/register',
  loginLimit,
  validateBody(RegisterSchema),
  asyncHandler(async (req, res) => {
    const result = await register(req.body);
    res.status(201).json(result);
  }),
);

authRouter.post(
  '/login',
  loginLimit,
  validateBody(LoginSchema),
  asyncHandler(async (req, res) => {
    const result = await login(req.body);
    res.json(result);
  }),
);

authRouter.post(
  '/google',
  loginLimit,
  validateBody(GoogleLoginSchema),
  asyncHandler(async (req, res) => {
    const result = await googleLogin(req.body);
    res.json(result);
  }),
);

authRouter.post(
  '/refresh',
  refreshLimit,
  validateBody(RefreshSchema),
  asyncHandler(async (req, res) => {
    const result = await refresh(req.body);
    res.json(result);
  }),
);

authRouter.post(
  '/logout',
  validateBody(LogoutSchema),
  asyncHandler(async (req, res) => {
    await logout(req.body);
    res.json({ ok: true });
  }),
);
