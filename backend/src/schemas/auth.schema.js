import { z } from 'zod';

export const RegisterSchema = z.object({
  email: z.string().trim().toLowerCase().email().max(254),
  password: z.string().min(8).max(128),
  displayName: z.string().trim().min(1).max(80),
});

export const LoginSchema = z.object({
  email: z.string().trim().toLowerCase().email().max(254),
  password: z.string().min(1).max(128),
});

export const RefreshSchema = z.object({
  refreshToken: z.string().min(10).max(512),
});

export const LogoutSchema = RefreshSchema;

export const UpdateMeSchema = z.object({
  displayName: z.string().trim().min(1).max(80),
});
