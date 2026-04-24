import Foundation
import GRDB

public final class SnippetRepository: @unchecked Sendable {
    public static let shared = SnippetRepository()

    private let dbPool: DatabasePool
    private let defaults: UserDefaults
    private let versionKey = "snippets.version"

    public init(
        dbPool: DatabasePool = DatabaseManager.shared.dbPool,
        defaults: UserDefaults = AppGroup.userDefaults
    ) {
        self.dbPool = dbPool
        self.defaults = defaults
    }

    /// Monotonic counter bumped whenever the snippet set changes. Read from any
    /// process (main app or keyboard extension) via the shared App Group UserDefaults
    /// to detect staleness without hitting SQLite.
    public var currentVersion: Int {
        defaults.integer(forKey: versionKey)
    }

    private func bumpVersion() {
        defaults.set(defaults.integer(forKey: versionKey) &+ 1, forKey: versionKey)
    }

    public func insert(_ snippet: Snippet) throws {
        try dbPool.write { db in
            try snippet.insert(db)
        }
        bumpVersion()
    }

    public func update(_ snippet: Snippet) throws {
        try dbPool.write { db in
            try snippet.update(db)
        }
        bumpVersion()
    }

    public func softDelete(clientId: String, at: Date = Date()) throws {
        try dbPool.write { db in
            try Snippet
                .filter(Snippet.Columns.clientId == clientId)
                .updateAll(db, [
                    Snippet.Columns.deletedAt.set(to: at),
                    Snippet.Columns.updatedAt.set(to: at)
                ])
        }
        bumpVersion()
    }

    public func listActive() throws -> [Snippet] {
        try dbPool.read { db in
            try Snippet
                .filter(Snippet.Columns.deletedAt == nil)
                .order(Snippet.Columns.updatedAt.desc)
                .fetchAll(db)
        }
    }

    public func find(clientId: String) throws -> Snippet? {
        try dbPool.read { db in
            try Snippet.filter(Snippet.Columns.clientId == clientId).fetchOne(db)
        }
    }

    public func listUnsynced() throws -> [Snippet] {
        try dbPool.read { db in
            try Snippet
                .filter(
                    Snippet.Columns.syncedAt == nil
                    || Snippet.Columns.updatedAt > Snippet.Columns.syncedAt
                )
                .fetchAll(db)
        }
    }

    public func upsert(_ snippet: Snippet) throws {
        try dbPool.write { db in
            try snippet.save(db)
        }
        bumpVersion()
    }
}
