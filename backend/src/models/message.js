import mongoose from 'mongoose';
import { TONE_VALUES } from './constants.js';

const MessageSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  clientId: { type: String, required: true },
  polishedText: { type: String, required: true },
  rawTranscript: { type: String, required: true },
  appBundleId: { type: String, default: '' },
  appName: { type: String, default: '' },
  toneUsed: { type: String, enum: TONE_VALUES, required: true },
  createdAt: { type: Date, required: true },
  updatedAt: { type: Date, required: true },
  deletedAt: { type: Date, default: null },
});

// Compound (userId, clientId) unique also covers userId-only queries via index prefix.
MessageSchema.index({ userId: 1, clientId: 1 }, { unique: true });
MessageSchema.index({ userId: 1, updatedAt: 1 });

export const Message = mongoose.model('Message', MessageSchema);
