import { User } from '../models/user.js';
import { NotFoundError } from '../utils/errors.js';

/** @param {string} userId */
export async function getProfile(userId) {
  const user = await User.findById(userId);
  if (!user) throw new NotFoundError('USER_NOT_FOUND', 'User not found.');
  return user.toPublic();
}

/**
 * @param {string} userId
 * @param {{ displayName: string }} updates
 */
export async function updateProfile(userId, updates) {
  const user = await User.findByIdAndUpdate(
    userId,
    { displayName: updates.displayName.trim() },
    { new: true },
  );
  if (!user) throw new NotFoundError('USER_NOT_FOUND', 'User not found.');
  return user.toPublic();
}
