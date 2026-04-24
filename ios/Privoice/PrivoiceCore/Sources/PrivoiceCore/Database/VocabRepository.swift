import Foundation
import GRDB

public final class VocabRepository: @unchecked Sendable {
    public static let shared = VocabRepository()

    private let dbPool: DatabasePool
    private let defaults: UserDefaults
    private let versionKey = "vocab.version"

    public init(
        dbPool: DatabasePool = DatabaseManager.shared.dbPool,
        defaults: UserDefaults = AppGroup.userDefaults
    ) {
        self.dbPool = dbPool
        self.defaults = defaults
    }

    /// Monotonic counter bumped whenever the vocab set changes. Readable from
    /// main app and keyboard extension via shared UserDefaults for cheap
    /// cross-process cache invalidation.
    public var currentVersion: Int {
        defaults.integer(forKey: versionKey)
    }

    private func bumpVersion() {
        defaults.set(defaults.integer(forKey: versionKey) &+ 1, forKey: versionKey)
    }

    public func insert(_ entry: VocabEntry) throws {
        try dbPool.write { db in
            try entry.insert(db)
        }
        bumpVersion()
    }

    public func update(_ entry: VocabEntry) throws {
        try dbPool.write { db in
            try entry.update(db)
        }
        bumpVersion()
    }

    public func softDelete(clientId: String, at: Date = Date()) throws {
        try dbPool.write { db in
            try VocabEntry
                .filter(VocabEntry.Columns.clientId == clientId)
                .updateAll(db, [
                    VocabEntry.Columns.deletedAt.set(to: at),
                    VocabEntry.Columns.updatedAt.set(to: at)
                ])
        }
        bumpVersion()
    }

    public func listActive() throws -> [VocabEntry] {
        try dbPool.read { db in
            try VocabEntry
                .filter(VocabEntry.Columns.deletedAt == nil)
                .order(VocabEntry.Columns.updatedAt.desc)
                .fetchAll(db)
        }
    }

    public func find(clientId: String) throws -> VocabEntry? {
        try dbPool.read { db in
            try VocabEntry.filter(VocabEntry.Columns.clientId == clientId).fetchOne(db)
        }
    }

    public func listUnsynced() throws -> [VocabEntry] {
        try dbPool.read { db in
            try VocabEntry
                .filter(
                    VocabEntry.Columns.syncedAt == nil
                    || VocabEntry.Columns.updatedAt > VocabEntry.Columns.syncedAt
                )
                .fetchAll(db)
        }
    }

    public func upsert(_ entry: VocabEntry) throws {
        try dbPool.write { db in
            try entry.save(db)
        }
        bumpVersion()
    }
}
