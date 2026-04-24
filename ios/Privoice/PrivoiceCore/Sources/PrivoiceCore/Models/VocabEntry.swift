import Foundation
import GRDB

/// A vocabulary entry: a word/phrase the speech recognizer should learn,
/// plus an optional `phonetic` alternate rendering.
public struct VocabEntry: Codable, Sendable, Equatable, Hashable, Identifiable, FetchableRecord, PersistableRecord {
    public var clientId: String
    public var word: String
    public var phonetic: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncedAt: Date?

    public var id: String { clientId }

    public init(
        clientId: String = UUID().uuidString.lowercased(),
        word: String,
        phonetic: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        syncedAt: Date? = nil
    ) {
        self.clientId = clientId
        self.word = word
        self.phonetic = phonetic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncedAt = syncedAt
    }

    public static let databaseTableName = "vocab"

    public enum Columns: String, ColumnExpression {
        case clientId, word, phonetic, createdAt, updatedAt, deletedAt, syncedAt
    }
}
