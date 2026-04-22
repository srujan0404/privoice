import { z } from 'zod';

export const PolishSchema = z.object({
  transcript: z.string().trim().min(1).max(4000),
  tone: z.enum(['casual', 'professional', 'friendly']),
  appName: z.string().trim().max(80).optional(),
});
