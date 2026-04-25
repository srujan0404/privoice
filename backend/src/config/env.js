import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().nonnegative().default(3000),
  LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),

  MONGODB_URI: z.string().url().or(z.string().startsWith('mongodb')),

  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  JWT_ACCESS_TTL: z.string().default('15m'),
  JWT_REFRESH_TTL: z.string().default('60d'),
  BCRYPT_ROUNDS: z.coerce.number().int().min(4).max(15).default(12),

  GROQ_API_KEY: z.string().min(1),
  GROQ_PRIMARY_MODEL: z.string().default('llama-3.3-70b-versatile'),
  GROQ_FALLBACK_MODEL: z.string().default('llama-3.1-8b-instant'),
  POLISH_PRIMARY_TIMEOUT_MS: z.coerce.number().int().positive().default(2500),
  POLISH_FALLBACK_TIMEOUT_MS: z.coerce.number().int().positive().default(1500),

  POLISH_CACHE_MAX: z.coerce.number().int().positive().default(1000),
  POLISH_CACHE_TTL_MS: z.coerce.number().int().positive().default(3_600_000),

  GOOGLE_OAUTH_IOS_CLIENT_ID: z.string().min(1),
});

const parsed = EnvSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('\n[env] Invalid environment:\n');
  for (const issue of parsed.error.issues) {
    console.error(`  - ${issue.path.join('.')}: ${issue.message}`);
  }
  console.error('');
  process.exit(1);
}

/** @type {z.infer<typeof EnvSchema>} */
export const env = parsed.data;
