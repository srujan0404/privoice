import mongoose from 'mongoose';

const VocabSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  clientId: { type: String, required: true },
  word: { type: String, required: true, maxlength: 80 },
  phonetic: { type: String, default: null, maxlength: 120 },
  createdAt: { type: Date, required: true },
  updatedAt: { type: Date, required: true },
  deletedAt: { type: Date, default: null },
});

VocabSchema.index({ userId: 1, clientId: 1 }, { unique: true });
VocabSchema.index({ userId: 1, updatedAt: 1 });

export const VocabEntry = mongoose.model('VocabEntry', VocabSchema);
