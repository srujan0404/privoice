import Groq from 'groq-sdk';
import { env } from '../config/env.js';

const client = new Groq({ apiKey: env.GROQ_API_KEY });

/**
 * Call Groq with a timeout. Throws on timeout or error.
 * @param {{ model: string, messages: any[], timeoutMs: number, maxTokens?: number }} opts
 * @returns {Promise<string>} assistant text content
 */
export async function chat({ model, messages, timeoutMs, maxTokens = 500 }) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(new Error('timeout')), timeoutMs);
  try {
    const completion = await client.chat.completions.create(
      { model, messages, max_tokens: maxTokens, temperature: 0.3 },
      { signal: controller.signal },
    );
    const text = completion.choices?.[0]?.message?.content ?? '';
    if (!text) throw new Error('empty completion');
    return text.trim();
  } finally {
    clearTimeout(timer);
  }
}
