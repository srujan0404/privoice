import mongoose from 'mongoose';

const NoteSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  clientId: { type: String, required: true },
  title: { type: String, default: '', maxlength: 80 },
  body: { type: String, default: '' },
  createdAt: { type: Date, required: true },
  updatedAt: { type: Date, required: true },
  deletedAt: { type: Date, default: null },
});

NoteSchema.index({ userId: 1, clientId: 1 }, { unique: true });
NoteSchema.index({ userId: 1, updatedAt: 1 });

export const Note = mongoose.model('Note', NoteSchema);
