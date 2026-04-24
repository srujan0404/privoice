import Foundation
import GRDB

/// Read/write access to the local messages table. Shared by the main app and the
/// keyboard extension via the App Group SQLite file.
public final class MessageRepository: @unchecked Sendable {
    public static let shared = MessageRepository()

    private let dbPool: DatabasePool

    public init(dbPool: DatabasePool = DatabaseManager.shared.dbPool) {
        self.dbPool = dbPool
    }

    /// Inserts a new message. Safe to call from the keyboard extension.
    public func insert(_ message: Message) throws {
        try dbPool.write { db in
            try message.insert(db)
        }
    }

    /// All active (non-deleted) messages ordered by creation time desc.
    public func listActive() throws -> [Message] {
        try dbPool.read { db in
            try Message
                .filter(Message.Columns.deletedAt == nil)
                .order(Message.Columns.createdAt.desc)
                .fetchAll(db)
        }
    }

    /// Messages that need to be pushed to the server (unsynced or updated since last sync).
    public func listUnsynced() throws -> [Message] {
        try dbPool.read { db in
            try Message
                .filter(
                    Message.Columns.syncedAt == nil
                    || Message.Columns.updatedAt > Message.Columns.syncedAt
                )
                .fetchAll(db)
        }
    }

    /// Upsert a server-authoritative record. Used by sync pull.
    public func upsert(_ message: Message) throws {
        try dbPool.write { db in
            try message.save(db)
        }
    }

    /// Marks a message as synced at `at` (saves over `syncedAt`).
    public func markSynced(clientId: String, at: Date) throws {
        try dbPool.write { db in
            try Message
                .filter(Message.Columns.clientId == clientId)
                .updateAll(db, Message.Columns.syncedAt.set(to: at))
        }
    }
}
