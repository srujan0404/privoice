import mongoose from 'mongoose';
import { env } from './env.js';
import { logger } from '../utils/logger.js';

mongoose.set('strictQuery', true);

// MVP: accepting Mongoose connection defaults (maxPoolSize=100, serverSelectionTimeoutMS=30s).
// Revisit when we have production traffic data; tune via explicit options here.

/**
 * Connect to MongoDB using env.MONGODB_URI. Logs a credential-masked URI on success.
 * @returns {Promise<void>}
 * @throws if connection fails (caller should treat as a fatal boot error)
 */
export async function connectDb() {
  await mongoose.connect(env.MONGODB_URI);
  logger.info({ uri: maskUri(env.MONGODB_URI) }, 'mongo connected');
}

/**
 * Disconnect from MongoDB. Safe to call during shutdown.
 * @returns {Promise<void>}
 */
export async function disconnectDb() {
  await mongoose.disconnect();
  logger.info('mongo disconnected');
}

/** @param {string} uri */
function maskUri(uri) {
  return uri.replace(/\/\/[^@]+@/, '//<credentials>@');
}
