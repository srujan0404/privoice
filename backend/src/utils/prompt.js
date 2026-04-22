/**
 * Build a Groq chat-completion messages array for a polish request.
 * @param {{ transcript: string, tone: 'casual'|'professional'|'friendly', appName?: string }} input
 * @returns {{ role: 'system' | 'user', content: string }[]}
 */
export function buildPolishMessages(input) {
  const app = input.appName && input.appName.trim().length > 0 ? input.appName.trim() : 'generic messaging';
  const system = [
    'You are a message polishing assistant.',
    'You receive a voice transcript that may contain disfluencies, filler words, and minor grammatical issues.',
    'Rewrite it to match the specified tone. Preserve meaning. Fix grammar.',
    'Do not add new information. Do not add greetings that were not in the original.',
    'Return only the rewritten text — no preamble, no quotes, no explanation.',
    '',
    `Tone: ${input.tone}`,
    `App: ${app}`,
  ].join('\n');
  return [
    { role: 'system', content: system },
    { role: 'user', content: input.transcript },
  ];
}
