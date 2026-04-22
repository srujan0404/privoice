import { z } from 'zod';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const isoDate = z.string().datetime();
const nullableIsoDate = z.string().datetime().nullable();
const clientId = z.string().regex(UUID_RE, 'must be a UUID v4');
const tone = z.enum(['casual', 'professional', 'friendly']);

const BaseRecord = {
  clientId,
  createdAt: isoDate,
  updatedAt: isoDate,
  deletedAt: nullableIsoDate.default(null),
};

export const MessageRecord = z.object({
  ...BaseRecord,
  polishedText: z.string().max(10_000),
  rawTranscript: z.string().max(10_000),
  appBundleId: z.string().max(255).default(''),
  appName: z.string().max(80).default(''),
  toneUsed: tone,
});

export const NoteRecord = z.object({
  ...BaseRecord,
  title: z.string().max(80).default(''),
  body: z.string().max(50_000).default(''),
});

export const SnippetRecord = z.object({
  ...BaseRecord,
  trigger: z.string().min(1).max(120),
  expansion: z.string().min(1).max(4000),
});

export const VocabRecord = z.object({
  ...BaseRecord,
  word: z.string().min(1).max(80),
  phonetic: z.string().max(120).nullable().default(null),
});

export const ToneSettingsRecord = z.object({
  globalTone: tone,
  appOverrides: z.record(z.string().max(255), tone).default({}),
  updatedAt: isoDate,
});

export const SyncQuerySchema = z.object({
  since: isoDate.optional(),
});

export const SyncPostSchema = z.object({
  messages: z.array(MessageRecord).default([]),
  notes: z.array(NoteRecord).default([]),
  snippets: z.array(SnippetRecord).default([]),
  vocab: z.array(VocabRecord).default([]),
  toneSettings: ToneSettingsRecord.optional().nullable(),
});
