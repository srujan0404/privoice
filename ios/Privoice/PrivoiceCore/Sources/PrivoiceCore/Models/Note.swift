import Foundation
import GRDB

/// A note, stored locally in SQLite and mirrored to the server via `/sync`.
public struct Note: Codable, Sendable, Equatable, Hashable, Identifiable, FetchableRecord, PersistableRecord {
    public var clientId: String
    public var title: String
    public var body: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncedAt: Date?

    public var id: String { clientId }

    public init(
        clientId: String = UUID().uuidString.lowercased(),
        title: String = "",
        body: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        syncedAt: Date? = nil
    ) {
        self.clientId = clientId
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncedAt = syncedAt
    }

    public static let databaseTableName = "notes"

    public enum Columns: String, ColumnExpression {
        case clientId, title, body, createdAt, updatedAt, deletedAt, syncedAt
    }

    /// First non-empty line used when the title is empty.
    public var displayTitle: String {
        if !title.isEmpty { return title }
        let firstLine = body.split(separator: "\n").first.map(String.init) ?? ""
        return firstLine.isEmpty ? "Untitled" : firstLine
    }

    /// A short preview used in list rows — body minus the first line if that line is the title.
    public var preview: String {
        if title.isEmpty {
            // Title was derived from first body line; skip that line in the preview.
            let lines = body.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
            return lines.count > 1 ? String(lines[1]).trimmingCharacters(in: .whitespacesAndNewlines) : ""
        }
        return body
    }
}
