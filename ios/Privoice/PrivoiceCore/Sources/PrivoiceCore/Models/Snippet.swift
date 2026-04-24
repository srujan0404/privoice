import Foundation
import GRDB

/// A text expansion: when the user dictates `trigger`, the keyboard inserts `expansion`.
/// Stored locally in SQLite and mirrored via `/sync`.
public struct Snippet: Codable, Sendable, Equatable, Hashable, Identifiable, FetchableRecord, PersistableRecord {
    public var clientId: String
    public var trigger: String
    public var expansion: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncedAt: Date?

    public var id: String { clientId }

    public init(
        clientId: String = UUID().uuidString.lowercased(),
        trigger: String,
        expansion: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        syncedAt: Date? = nil
    ) {
        self.clientId = clientId
        self.trigger = trigger
        self.expansion = expansion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncedAt = syncedAt
    }

    public static let databaseTableName = "snippets"

    public enum Columns: String, ColumnExpression {
        case clientId, trigger, expansion, createdAt, updatedAt, deletedAt, syncedAt
    }
}
