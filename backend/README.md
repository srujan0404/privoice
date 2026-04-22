# PocketVoice Backend

Node.js + MongoDB backend for the PocketVoice iOS app. Provides email/password auth, cross-device sync for user data, and an AI tone-polish proxy via Groq.

## Quick start

```bash
cd backend
npm install
cp .env.example .env
# fill in MONGODB_URI (Atlas or local), GROQ_API_KEY, and generate 32+ char JWT secrets

# Optional for tests:
cp .env.test.example .env.test
# point MONGODB_URI at a separate test DB so tests never touch dev data

npm run dev
```

Server listens on `http://localhost:3000`. Smoke check: `curl http://localhost:3000/health` → `{"ok":true}`.

## Scripts

| Script | Purpose |
|---|---|
| `npm run dev` | Watch mode via Node's built-in `--watch` |
| `npm start` | Production mode |
| `npm test` | Run any colocated test files once |
| `npm run test:watch` | Tests in watch mode |

## Endpoints

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/auth/register` | none | Create account → `{accessToken, refreshToken, user}` |
| POST | `/auth/login` | none | Same shape for valid credentials |
| POST | `/auth/refresh` | refresh token in body | Atomic CAS rotation → new pair |
| POST | `/auth/logout` | refresh token in body | Idempotent revoke |
| GET | `/me` | Bearer | Current user profile |
| PATCH | `/me` | Bearer | Update `displayName` |
| GET | `/sync?since=<ISO>` | Bearer | Pull records modified after `since` (omit for full pull) |
| POST | `/sync` | Bearer | Push batch; server merges with last-write-wins, echoes winners |
| POST | `/polish` | Bearer | Run text through Groq 70B → 8B → raw cascade |
| GET | `/health` | none | `{ok: true}` |

All responses are JSON. Errors use the envelope `{"error": {"code", "message", "details"}}`.

## Standard error codes

| Code | HTTP | Meaning |
|---|---|---|
| `VALIDATION_FAILED` | 400 | Zod validation; `details` carries per-field errors |
| `INVALID_JSON` | 400 | Malformed request body |
| `AUTH_TOKEN_INVALID` | 401 | Missing/invalid/expired access or refresh token |
| `AUTH_INVALID_CREDENTIALS` | 401 | Wrong email or password |
| `NOT_FOUND` / `USER_NOT_FOUND` | 404 | Route or resource not found |
| `AUTH_EMAIL_TAKEN` | 409 | Register with an existing email |
| `PAYLOAD_TOO_LARGE` | 413 | Body exceeds 2 MB |
| `UNSUPPORTED_MEDIA_TYPE` | 415 | Unsupported encoding/charset |
| `RATE_LIMITED` | 429 | Per-user or per-IP throttle exceeded |
| `INTERNAL` | 500 | Unhandled server error |

## Security + operations notes

- **Passwords**: bcrypt with `env.BCRYPT_ROUNDS` (default 12; tests use 4).
- **JWT**: HS256 pinned on sign + verify. Access tokens 15 min, refresh tokens 60 days, rotated atomically on every `/auth/refresh` via a CAS update (concurrent double-mint prevented).
- **Timing-attack guard**: login compares against a dummy bcrypt hash on unknown emails so wall-clock time doesn't leak account existence.
- **Request correlation**: every request gets an `X-Request-Id` (from header or a fresh UUID), echoed back on the response and tagged on every log line.
- **Logs**: Pino structured JSON to stdout; passwords, authorization headers, refresh/access tokens, and set-cookie are redacted.
- **Helmet** + CORS (currently permissive; tighten before exposing to a web client).
- **Rate limits**: `/auth/login` and `/auth/register` share 10 req/min/IP; `/auth/refresh` 30 req/min/IP; `/sync` 600 req/min/user; `/polish` 60 req/min/user.

## Sync model (last-write-wins)

- Each client-authored record carries a `clientId` (UUID v4) that serves as the idempotency key per user.
- Server-side storage carries `createdAt`, `updatedAt`, and a `deletedAt` tombstone — all client-authored for the four sync collections (messages, notes, snippets, vocab).
- `ToneSettings` is one-per-user with a client-authored `updatedAt` for LWW.
- Soft delete: clients bump `updatedAt` and set `deletedAt`; the server propagates the tombstone to other devices.

See the full design in `docs/superpowers/specs/2026-04-22-pocketvoice-backend-design.md`.

## Deployment

Runs on any host that can `npm install && npm start` with Node 20+. Provide env vars per `.env.example`. Logs are structured JSON on stdout; capture with the host platform's log tail.
