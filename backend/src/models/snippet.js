import mongoose from 'mongoose';

const SnippetSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  clientId: { type: String, required: true },
  trigger: { type: String, required: true, maxlength: 120 },
  expansion: { type: String, required: true },
  createdAt: { type: Date, required: true },
  updatedAt: { type: Date, required: true },
  deletedAt: { type: Date, default: null },
});

SnippetSchema.index({ userId: 1, clientId: 1 }, { unique: true });
SnippetSchema.index({ userId: 1, updatedAt: 1 });

export const Snippet = mongoose.model('Snippet', SnippetSchema);
