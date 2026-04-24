import Foundation

// MARK: - DTOs

public struct MessageDTO: Codable, Sendable {
    public let clientId: String
    public let polishedText: String
    public let rawTranscript: String
    public let appBundleId: String
    public let appName: String
    public let toneUsed: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?

    public init(_ message: Message) {
        self.clientId = message.clientId
        self.polishedText = message.polishedText
        self.rawTranscript = message.rawTranscript
        self.appBundleId = message.appBundleId
        self.appName = message.appName
        self.toneUsed = message.toneUsed
        self.createdAt = message.createdAt
        self.updatedAt = message.updatedAt
        self.deletedAt = message.deletedAt
    }

    public func asMessage(syncedAt: Date) -> Message {
        Message(
            clientId: clientId,
            polishedText: polishedText,
            rawTranscript: rawTranscript,
            appBundleId: appBundleId,
            appName: appName,
            toneUsed: Tone(rawValue: toneUsed) ?? .default,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncedAt: syncedAt
        )
    }
}

public struct NoteDTO: Codable, Sendable {
    public let clientId: String
    public let title: String
    public let body: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?

    public init(_ note: Note) {
        self.clientId = note.clientId
        self.title = note.title
        self.body = note.body
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
        self.deletedAt = note.deletedAt
    }

    public func asNote(syncedAt: Date) -> Note {
        Note(
            clientId: clientId,
            title: title,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncedAt: syncedAt
        )
    }
}

public struct SnippetDTO: Codable, Sendable {
    public let clientId: String
    public let trigger: String
    public let expansion: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?

    public init(_ snippet: Snippet) {
        self.clientId = snippet.clientId
        self.trigger = snippet.trigger
        self.expansion = snippet.expansion
        self.createdAt = snippet.createdAt
        self.updatedAt = snippet.updatedAt
        self.deletedAt = snippet.deletedAt
    }

    public func asSnippet(syncedAt: Date) -> Snippet {
        Snippet(
            clientId: clientId,
            trigger: trigger,
            expansion: expansion,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncedAt: syncedAt
        )
    }
}

public struct VocabDTO: Codable, Sendable {
    public let clientId: String
    public let word: String
    public let phonetic: String?
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?

    public init(_ entry: VocabEntry) {
        self.clientId = entry.clientId
        self.word = entry.word
        self.phonetic = entry.phonetic
        self.createdAt = entry.createdAt
        self.updatedAt = entry.updatedAt
        self.deletedAt = entry.deletedAt
    }

    public func asVocab(syncedAt: Date) -> VocabEntry {
        VocabEntry(
            clientId: clientId,
            word: word,
            phonetic: phonetic,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncedAt: syncedAt
        )
    }
}

// MARK: - Request / Response shapes

public struct SyncPullResponse: Codable, Sendable {
    public let messages: [MessageDTO]
    public let notes: [NoteDTO]
    public let snippets: [SnippetDTO]
    public let vocab: [VocabDTO]
    public let serverTime: Date
}

public struct SyncPushBody: Codable, Sendable {
    public let messages: [MessageDTO]
    public let notes: [NoteDTO]
    public let snippets: [SnippetDTO]
    public let vocab: [VocabDTO]
}

public struct SyncPushResponse: Codable, Sendable {
    public let messages: [MessageDTO]
    public let notes: [NoteDTO]
    public let snippets: [SnippetDTO]
    public let vocab: [VocabDTO]
    public let serverTime: Date
}

// MARK: - API

public enum SyncAPI {
    public static func pull(since: Date? = nil) async throws -> SyncPullResponse {
        var path = "sync"
        if let since {
            let iso = ISO8601DateFormatter().string(from: since)
            let escaped = iso.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? iso
            path += "?since=\(escaped)"
        }
        return try await APIClient.shared.authed("GET", path, response: SyncPullResponse.self)
    }

    public static func push(
        messages: [Message],
        notes: [Note],
        snippets: [Snippet],
        vocab: [VocabEntry]
    ) async throws -> SyncPushResponse {
        let body = SyncPushBody(
            messages: messages.map(MessageDTO.init),
            notes: notes.map(NoteDTO.init),
            snippets: snippets.map(SnippetDTO.init),
            vocab: vocab.map(VocabDTO.init)
        )
        return try await APIClient.shared.authed("POST", "sync", body: body, response: SyncPushResponse.self)
    }
}
