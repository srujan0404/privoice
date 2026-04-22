import mongoose from 'mongoose';
import { TONE_VALUES } from './constants.js';

const ToneSettingsSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    globalTone: { type: String, enum: TONE_VALUES, default: 'casual' },
    // Map → factory default avoids shared-reference footgun; flattenMaps in options
    // emits plain objects from toJSON/toObject so Zod and clients see a POJO, not a Map.
    appOverrides: { type: Map, of: String, default: () => new Map() },
    // Client-authored for last-write-wins merge (see spec §7.4). NOT auto-managed.
    updatedAt: { type: Date, required: true },
  },
  {
    toJSON: { flattenMaps: true },
    toObject: { flattenMaps: true },
  },
);

export const ToneSettings = mongoose.model('ToneSettings', ToneSettingsSchema);
