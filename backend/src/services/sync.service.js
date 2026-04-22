import { Message } from '../models/message.js';
import { Note } from '../models/note.js';
import { Snippet } from '../models/snippet.js';
import { VocabEntry } from '../models/vocab.js';
import { ToneSettings } from '../models/toneSettings.js';

const COLLECTIONS = [
  { key: 'messages', Model: Message, fields: ['polishedText', 'rawTranscript', 'appBundleId', 'appName', 'toneUsed'] },
  { key: 'notes', Model: Note, fields: ['title', 'body'] },
  { key: 'snippets', Model: Snippet, fields: ['trigger', 'expansion'] },
  { key: 'vocab', Model: VocabEntry, fields: ['word', 'phonetic'] },
];

/**
 * Pull all records modified after `since` for a given user.
 * @param {string} userId
 * @param {string | undefined} sinceIso
 */
export async function pullSince(userId, sinceIso) {
  const filter = { userId };
  if (sinceIso) filter.updatedAt = { $gt: new Date(sinceIso) };

  const [messages, notes, snippets, vocab, toneSettings] = await Promise.all([
    Message.find(filter).lean(),
    Note.find(filter).lean(),
    Snippet.find(filter).lean(),
    VocabEntry.find(filter).lean(),
    ToneSettings.findOne({ userId, ...(sinceIso ? { updatedAt: { $gt: new Date(sinceIso) } } : {}) }).lean(),
  ]);

  return {
    messages: messages.map(serializeRecord),
    notes: notes.map(serializeRecord),
    snippets: snippets.map(serializeRecord),
    vocab: vocab.map(serializeRecord),
    toneSettings: toneSettings ? serializeTone(toneSettings) : null,
    serverTime: new Date().toISOString(),
  };
}

/**
 * Push a batch of client-side changes with last-write-wins merge.
 * Returns the server-winning version of every submitted record.
 * @param {string} userId
 * @param {{ messages?: any[], notes?: any[], snippets?: any[], vocab?: any[], toneSettings?: any }} batch
 */
export async function pushBatch(userId, batch) {
  const response = { messages: [], notes: [], snippets: [], vocab: [], toneSettings: null };

  for (const { key, Model, fields } of COLLECTIONS) {
    const records = batch[key] ?? [];
    for (const incoming of records) {
      const winner = await mergeRecord(Model, userId, incoming, fields);
      response[key].push(serializeRecord(winner));
    }
  }

  if (batch.toneSettings) {
    const winner = await mergeToneSettings(userId, batch.toneSettings);
    response.toneSettings = serializeTone(winner);
  }

  return response;
}

async function mergeRecord(Model, userId, incoming, fields) {
  const existing = await Model.findOne({ userId, clientId: incoming.clientId });
  const clientUpdatedAt = new Date(incoming.updatedAt);

  if (!existing) {
    const payload = {
      userId,
      clientId: incoming.clientId,
      createdAt: new Date(incoming.createdAt),
      updatedAt: clientUpdatedAt,
      deletedAt: incoming.deletedAt ? new Date(incoming.deletedAt) : null,
    };
    for (const f of fields) payload[f] = incoming[f];
    return Model.create(payload);
  }

  if (clientUpdatedAt > existing.updatedAt) {
    for (const f of fields) existing[f] = incoming[f];
    existing.updatedAt = clientUpdatedAt;
    existing.deletedAt = incoming.deletedAt ? new Date(incoming.deletedAt) : null;
    await existing.save();
  }
  return existing;
}

async function mergeToneSettings(userId, incoming) {
  const existing = await ToneSettings.findOne({ userId });
  const clientUpdatedAt = new Date(incoming.updatedAt);

  const encoded = encodeOverrides(incoming.appOverrides || {});

  if (!existing) {
    return ToneSettings.create({
      userId,
      globalTone: incoming.globalTone,
      appOverrides: encoded,
      updatedAt: clientUpdatedAt,
    });
  }

  if (clientUpdatedAt > existing.updatedAt) {
    existing.globalTone = incoming.globalTone;
    existing.appOverrides = encoded;
    existing.updatedAt = clientUpdatedAt;
    await existing.save();
  }
  return existing;
}

// Mongoose Map keys cannot contain '.'; encode as U+FF0E fullwidth stop.
const DOT = '.';
const DOT_ESCAPE = '．';
function encodeOverrides(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) out[k.split(DOT).join(DOT_ESCAPE)] = v;
  return out;
}
function decodeOverrides(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) out[k.split(DOT_ESCAPE).join(DOT)] = v;
  return out;
}

function serializeRecord(doc) {
  const d = doc.toObject ? doc.toObject() : doc;
  const out = {
    clientId: d.clientId,
    createdAt: d.createdAt instanceof Date ? d.createdAt.toISOString() : d.createdAt,
    updatedAt: d.updatedAt instanceof Date ? d.updatedAt.toISOString() : d.updatedAt,
    deletedAt: d.deletedAt ? (d.deletedAt instanceof Date ? d.deletedAt.toISOString() : d.deletedAt) : null,
  };
  // Include each collection's specific fields only when present on the doc
  for (const f of ['polishedText', 'rawTranscript', 'appBundleId', 'appName', 'toneUsed',
                   'title', 'body', 'trigger', 'expansion', 'word', 'phonetic']) {
    if (d[f] !== undefined) out[f] = d[f];
  }
  return out;
}

function serializeTone(doc) {
  const d = doc.toObject ? doc.toObject() : doc;
  const raw = d.appOverrides instanceof Map ? Object.fromEntries(d.appOverrides) : d.appOverrides || {};
  return {
    globalTone: d.globalTone,
    appOverrides: decodeOverrides(raw),
    updatedAt: d.updatedAt instanceof Date ? d.updatedAt.toISOString() : d.updatedAt,
  };
}
