import { LRUCache } from 'lru-cache';
import { env } from '../config/env.js';
import { sha256Hex } from '../utils/hash.js';

const cache = new LRUCache({
  max: env.POLISH_CACHE_MAX,
  ttl: env.POLISH_CACHE_TTL_MS,
});

/**
 * @param {{ transcript: string, tone: string, appName?: string }} input
 * @returns {string}
 */
export function cacheKey(input) {
  return sha256Hex(`${input.transcript}|${input.tone}|${input.appName ?? ''}`);
}

export function cacheGet(key) {
  return cache.get(key);
}

export function cacheSet(key, value) {
  cache.set(key, value);
}

export function _resetCacheForTests() {
  cache.clear();
}
