import { env } from '../config/env.js';
import { logger } from '../utils/logger.js';
import { chat } from './groq.service.js';
import { buildPolishMessages } from '../utils/prompt.js';
import { cacheKey, cacheGet, cacheSet } from './cache.service.js';

/**
 * @param {{ transcript: string, tone: 'casual'|'professional'|'friendly', appName?: string }} input
 * @returns {Promise<{ polishedText: string, provider: 'groq-70b'|'groq-8b'|'fallback-raw', latencyMs: number }>}
 */
export async function polish(input) {
  const started = Date.now();
  const key = cacheKey(input);
  const cached = cacheGet(key);
  if (cached) {
    return { ...cached, latencyMs: Date.now() - started };
  }

  const messages = buildPolishMessages(input);

  try {
    const text = await chat({
      model: env.GROQ_PRIMARY_MODEL,
      messages,
      timeoutMs: env.POLISH_PRIMARY_TIMEOUT_MS,
    });
    const out = { polishedText: text, provider: 'groq-70b' };
    cacheSet(key, out);
    return { ...out, latencyMs: Date.now() - started };
  } catch (err) {
    logger.warn({ err: String(err), model: env.GROQ_PRIMARY_MODEL }, 'polish primary failed');
  }

  try {
    const text = await chat({
      model: env.GROQ_FALLBACK_MODEL,
      messages,
      timeoutMs: env.POLISH_FALLBACK_TIMEOUT_MS,
    });
    const out = { polishedText: text, provider: 'groq-8b' };
    cacheSet(key, out);
    return { ...out, latencyMs: Date.now() - started };
  } catch (err) {
    logger.warn({ err: String(err), model: env.GROQ_FALLBACK_MODEL }, 'polish fallback failed');
  }

  return { polishedText: input.transcript, provider: 'fallback-raw', latencyMs: Date.now() - started };
}
