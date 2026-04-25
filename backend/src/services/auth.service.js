import bcrypt from 'bcrypt';
import crypto from 'node:crypto';
import { OAuth2Client } from 'google-auth-library';
import { env } from '../config/env.js';
import { User } from '../models/user.js';
import { RefreshToken } from '../models/refreshToken.js';
import { AuthError } from '../utils/errors.js';
import { signAccessToken, generateRefreshToken, hashRefreshToken } from './token.service.js';

const DUMMY_PASSWORD_HASH = bcrypt.hashSync('not-a-real-password', env.BCRYPT_ROUNDS);
const googleAuthClient = new OAuth2Client();

/**
 * @param {{ email: string, password: string, displayName: string }} input
 */
export async function register(input) {
  const email = input.email.trim().toLowerCase();

  const existing = await User.findOne({ email });
  if (existing) throw new AuthError('AUTH_EMAIL_TAKEN', 'Email already registered.', 409);

  const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_ROUNDS);

  try {
    const user = await User.create({ email, passwordHash, displayName: input.displayName.trim() });
    return issueTokens(user);
  } catch (err) {
    if (err && err.code === 11000) {
      throw new AuthError('AUTH_EMAIL_TAKEN', 'Email already registered.', 409);
    }
    throw err;
  }
}

/**
 * @param {{ email: string, password: string }} input
 */
export async function login(input) {
  const email = input.email.trim().toLowerCase();
  const user = await User.findOne({ email });

  const ok = await bcrypt.compare(input.password, user ? user.passwordHash : DUMMY_PASSWORD_HASH);
  if (!user || !ok) {
    throw new AuthError('AUTH_INVALID_CREDENTIALS', 'Email or password is incorrect.');
  }

  return issueTokens(user);
}

/**
 * Internal: issue access+refresh pair for an authenticated user.
 * @param {InstanceType<typeof User>} user
 */
async function issueTokens(user) {
  const accessToken = signAccessToken(user._id.toString());
  const { token: refreshToken, hash, expiresAt } = generateRefreshToken();
  await RefreshToken.create({ userId: user._id, tokenHash: hash, expiresAt });
  return { accessToken, refreshToken, user: user.toPublic() };
}

/**
 * Rotate a refresh token: atomically revoke the presented one, then issue a new pair.
 * The atomic findOneAndUpdate is a CAS — only one concurrent caller can flip
 * `revokedAt` from null to a Date, so double-mint under concurrent refresh is prevented.
 * @param {{ refreshToken: string }} input
 */
export async function refresh(input) {
  const hash = hashRefreshToken(input.refreshToken);
  const now = new Date();

  const row = await RefreshToken.findOneAndUpdate(
    { tokenHash: hash, revokedAt: null, expiresAt: { $gt: now } },
    { revokedAt: now },
    { new: false },
  );
  if (!row) throw new AuthError('AUTH_TOKEN_INVALID', 'Refresh token is invalid.');

  const user = await User.findById(row.userId);
  if (!user) throw new AuthError('AUTH_TOKEN_INVALID', 'Refresh token is invalid.');

  return issueTokens(user);
}

/**
 * Verify a Google-issued iOS ID token, then either link it to an existing
 * email-matched account or provision a new one. Returns the standard
 * access/refresh pair so the iOS client treats it identically to /login.
 * @param {{ idToken: string }} input
 */
export async function googleLogin(input) {
  let payload;
  try {
    const ticket = await googleAuthClient.verifyIdToken({
      idToken: input.idToken,
      audience: env.GOOGLE_OAUTH_IOS_CLIENT_ID,
    });
    payload = ticket.getPayload();
  } catch {
    throw new AuthError('AUTH_GOOGLE_INVALID_TOKEN', 'Google sign-in token is invalid or expired.');
  }
  if (!payload || !payload.sub || !payload.email || !payload.email_verified) {
    throw new AuthError('AUTH_GOOGLE_INVALID_TOKEN', 'Google account email is not verified.');
  }

  const email = payload.email.toLowerCase();
  const googleSub = payload.sub;
  const displayName = (payload.name && payload.name.trim()) || email.split('@')[0];

  let user = await User.findOne({ $or: [{ googleSub }, { email }] });
  if (user) {
    if (!user.googleSub) {
      user.googleSub = googleSub;
      await user.save();
    }
  } else {
    // Random unguessable password so password login can never succeed for a Google-provisioned account.
    const passwordHash = await bcrypt.hash(crypto.randomBytes(32).toString('hex'), env.BCRYPT_ROUNDS);
    user = await User.create({ email, displayName, googleSub, passwordHash });
  }
  return issueTokens(user);
}

/**
 * Revoke a refresh token. Safe to call with an unknown token (no-op).
 * The `revokedAt: null` predicate keeps the op idempotent — a second logout
 * against an already-revoked row does not overwrite the original revocation time.
 * @param {{ refreshToken: string }} input
 */
export async function logout(input) {
  const hash = hashRefreshToken(input.refreshToken);
  await RefreshToken.updateOne({ tokenHash: hash, revokedAt: null }, { revokedAt: new Date() });
}
