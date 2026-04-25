import Foundation

/// Orchestrates push/pull sync. Last server time is persisted in App Group UserDefaults
/// so incremental pulls work across launches.
@MainActor
public final class SyncCoordinator {
    public static let shared = SyncCoordinator()

    private let messages: MessageRepository
    private let notes: NoteRepository
    private let snippets: SnippetRepository
    private let vocab: VocabRepository
    private let defaults: UserDefaults
    private let lastServerTimeKey = "sync.lastServerTime"

    private var isRunning = false

    public init(
        messages: MessageRepository = .shared,
        notes: NoteRepository = .shared,
        snippets: SnippetRepository = .shared,
        vocab: VocabRepository = .shared,
        defaults: UserDefaults = AppGroup.userDefaults
    ) {
        self.messages = messages
        self.notes = notes
        self.snippets = snippets
        self.vocab = vocab
        self.defaults = defaults
    }

    public var lastServerTime: Date? {
        get {
            guard let iso = defaults.string(forKey: lastServerTimeKey) else { return nil }
            return ISO8601DateFormatter().date(from: iso)
        }
        set {
            if let newValue {
                defaults.set(ISO8601DateFormatter().string(from: newValue), forKey: lastServerTimeKey)
            } else {
                defaults.removeObject(forKey: lastServerTimeKey)
            }
        }
    }

    /// Last error from the most recent run (nil on success). Useful for debug UI.
    public private(set) var lastError: String?

    /// Pushes local unsynced changes then pulls anything new from the server.
    /// Swallows errors so the UI still renders local data — but records them
    /// on `lastError` and prints them to the console so they're diagnosable.
    public func run() async {
        guard !isRunning else { return }
        isRunning = true
        defer { isRunning = false }

        NSLog("[Sync] run() start")
        do {
            try await push()
            try await pull()
            lastError = nil
            NSLog("[Sync] OK")
        } catch {
            lastError = "\(error)"
            NSLog("[Sync] FAILED: %@", "\(error)")
        }
    }

    private func push() async throws {
        let rawMessages = try messages.listUnsynced()
        let rawNotes = try notes.listUnsynced()
        let rawSnippets = try snippets.listUnsynced()
        let rawVocab = try vocab.listUnsynced()
        NSLog("[Sync] push queue: messages=%d notes=%d snippets=%d vocab=%d", rawMessages.count, rawNotes.count, rawSnippets.count, rawVocab.count)

        let unsyncedMessages = rawMessages.filter { Self.assertValidClientId($0.clientId, kind: "message") }
        let unsyncedNotes = rawNotes.filter { Self.assertValidClientId($0.clientId, kind: "note") }
        let unsyncedSnippets = rawSnippets.filter { Self.assertValidClientId($0.clientId, kind: "snippet") }
        let unsyncedVocab = rawVocab.filter { Self.assertValidClientId($0.clientId, kind: "vocab") }

        guard !unsyncedMessages.isEmpty
            || !unsyncedNotes.isEmpty
            || !unsyncedSnippets.isEmpty
            || !unsyncedVocab.isEmpty
        else { return }

        let response = try await SyncAPI.push(
            messages: unsyncedMessages,
            notes: unsyncedNotes,
            snippets: unsyncedSnippets,
            vocab: unsyncedVocab
        )
        let syncedAt = response.serverTime
        for dto in response.messages {
            try messages.upsert(dto.asMessage(syncedAt: syncedAt))
        }
        for dto in response.notes {
            try notes.upsert(dto.asNote(syncedAt: syncedAt))
        }
        for dto in response.snippets {
            try snippets.upsert(dto.asSnippet(syncedAt: syncedAt))
        }
        for dto in response.vocab {
            try vocab.upsert(dto.asVocab(syncedAt: syncedAt))
        }
        NSLog("[Sync] push OK: synced %d records", response.messages.count + response.notes.count + response.snippets.count + response.vocab.count)
    }

    private func pull() async throws {
        let since = lastServerTime
        NSLog("[Sync] pull since=%@", since?.description ?? "nil")
        let response = try await SyncAPI.pull(since: since)
        for dto in response.messages {
            try messages.upsert(dto.asMessage(syncedAt: response.serverTime))
        }
        for dto in response.notes {
            try notes.upsert(dto.asNote(syncedAt: response.serverTime))
        }
        for dto in response.snippets {
            try snippets.upsert(dto.asSnippet(syncedAt: response.serverTime))
        }
        for dto in response.vocab {
            try vocab.upsert(dto.asVocab(syncedAt: response.serverTime))
        }
        lastServerTime = response.serverTime
        NSLog("[Sync] pull OK: messages=%d notes=%d snippets=%d vocab=%d", response.messages.count, response.notes.count, response.snippets.count, response.vocab.count)
    }

    private static let uuidV4Regex = try! NSRegularExpression(
        pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
        options: [.caseInsensitive]
    )

    private static func assertValidClientId(_ clientId: String, kind: String) -> Bool {
        let range = NSRange(clientId.startIndex..., in: clientId)
        let ok = uuidV4Regex.firstMatch(in: clientId, options: [], range: range) != nil
        if !ok {
            NSLog("[Sync] dropping %@ with non-v4 clientId from push: %@", kind, clientId)
        }
        return ok
    }
}
