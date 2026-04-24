import Foundation
import GRDB

/// Manages the shared SQLite database at App Group container.
/// Schema is intentionally empty in Sub-project 1 — tables are added in Sub-project 3.
public final class DatabaseManager: @unchecked Sendable {
    public static let shared = DatabaseManager()

    public let dbPool: DatabasePool

    public init(url: URL = AppGroup.databaseURL) {
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode = WAL")
        }
        do {
            self.dbPool = try DatabasePool(path: url.path, configuration: config)
        } catch {
            fatalError("Failed to open database at \(url.path): \(error)")
        }
        try? runMigrations()
    }

    private func runMigrations() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_bootstrap") { _ in
            // Intentionally empty — real tables land in later migrations.
        }

        migrator.registerMigration("v2_messages") { db in
            try db.create(table: "messages") { t in
                t.column("clientId", .text).primaryKey()
                t.column("polishedText", .text).notNull()
                t.column("rawTranscript", .text).notNull()
                t.column("appBundleId", .text).notNull().defaults(to: "")
                t.column("appName", .text).notNull().defaults(to: "")
                t.column("toneUsed", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("deletedAt", .datetime)
                t.column("syncedAt", .datetime)
            }
            try db.create(indexOn: "messages", columns: ["createdAt"])
            try db.create(indexOn: "messages", columns: ["syncedAt"])
        }

        migrator.registerMigration("v3_notes") { db in
            try db.create(table: "notes") { t in
                t.column("clientId", .text).primaryKey()
                t.column("title", .text).notNull().defaults(to: "")
                t.column("body", .text).notNull().defaults(to: "")
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("deletedAt", .datetime)
                t.column("syncedAt", .datetime)
            }
            try db.create(indexOn: "notes", columns: ["updatedAt"])
            try db.create(indexOn: "notes", columns: ["syncedAt"])
        }

        try migrator.migrate(dbPool)
    }
}
