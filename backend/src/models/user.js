import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    displayName: { type: String, required: true, trim: true, maxlength: 80 },
    googleSub: { type: String, index: true, sparse: true },
  },
  { timestamps: true },
);

/**
 * Returns a public-safe view of the user (no passwordHash).
 * @returns {{ id: string, email: string, displayName: string, createdAt: string | null }}
 */
UserSchema.methods.toPublic = function toPublic() {
  return {
    id: this._id.toString(),
    email: this.email,
    displayName: this.displayName,
    createdAt: this.createdAt ? this.createdAt.toISOString() : null,
  };
};

export const User = mongoose.model('User', UserSchema);
