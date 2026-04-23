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

        // Sub-project 1: no tables yet. This empty migration just confirms the migrator runs.
        migrator.registerMigration("v1_bootstrap") { _ in
            // Intentionally empty — real tables land in Sub-project 3.
        }

        try migrator.migrate(dbPool)
    }
}
