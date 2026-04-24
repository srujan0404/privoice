import Foundation
import GRDB

public final class NoteRepository: @unchecked Sendable {
    public static let shared = NoteRepository()

    private let dbPool: DatabasePool

    public init(dbPool: DatabasePool = DatabaseManager.shared.dbPool) {
        self.dbPool = dbPool
    }

    public func insert(_ note: Note) throws {
        try dbPool.write { db in
            try note.insert(db)
        }
    }

    public func update(_ note: Note) throws {
        try dbPool.write { db in
            try note.update(db)
        }
    }

    /// Soft delete — sets `deletedAt` and bumps `updatedAt`. Server reconciliation preserves this.
    public func softDelete(clientId: String, at: Date = Date()) throws {
        try dbPool.write { db in
            try Note
                .filter(Note.Columns.clientId == clientId)
                .updateAll(db, [
                    Note.Columns.deletedAt.set(to: at),
                    Note.Columns.updatedAt.set(to: at)
                ])
        }
    }

    public func listActive() throws -> [Note] {
        try dbPool.read { db in
            try Note
                .filter(Note.Columns.deletedAt == nil)
                .order(Note.Columns.updatedAt.desc)
                .fetchAll(db)
        }
    }

    public func find(clientId: String) throws -> Note? {
        try dbPool.read { db in
            try Note.filter(Note.Columns.clientId == clientId).fetchOne(db)
        }
    }

    public func listUnsynced() throws -> [Note] {
        try dbPool.read { db in
            try Note
                .filter(
                    Note.Columns.syncedAt == nil
                    || Note.Columns.updatedAt > Note.Columns.syncedAt
                )
                .fetchAll(db)
        }
    }

    public func upsert(_ note: Note) throws {
        try dbPool.write { db in
            try note.save(db)
        }
    }
}
