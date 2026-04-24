import Foundation
import GRDB

/// A polished dictation entry, recorded locally in SQLite and mirrored to the server
/// via `/sync`. `clientId` is the stable UUID that identifies the record across devices.
public struct Message: Codable, Sendable, Equatable, Identifiable, FetchableRecord, PersistableRecord {
    public var clientId: String
    public var polishedText: String
    public var rawTranscript: String
    public var appBundleId: String
    public var appName: String
    public var toneUsed: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncedAt: Date?

    public var id: String { clientId }

    public var tone: Tone { Tone(rawValue: toneUsed) ?? .default }

    public init(
        clientId: String = UUID().uuidString.lowercased(),
        polishedText: String,
        rawTranscript: String,
        appBundleId: String = "",
        appName: String = "",
        toneUsed: Tone,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        syncedAt: Date? = nil
    ) {
        self.clientId = clientId
        self.polishedText = polishedText
        self.rawTranscript = rawTranscript
        self.appBundleId = appBundleId
        self.appName = appName
        self.toneUsed = toneUsed.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncedAt = syncedAt
    }

    public static let databaseTableName = "messages"

    public enum Columns: String, ColumnExpression {
        case clientId, polishedText, rawTranscript, appBundleId, appName, toneUsed
        case createdAt, updatedAt, deletedAt, syncedAt
    }
}
