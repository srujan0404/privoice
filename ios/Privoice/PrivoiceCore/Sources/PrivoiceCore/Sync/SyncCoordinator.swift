import Foundation

/// Orchestrates push/pull sync. Last server time is persisted in App Group UserDefaults
/// so incremental pulls work across launches.
@MainActor
public final class SyncCoordinator {
    public static let shared = SyncCoordinator()

    private let messages: MessageRepository
    private let notes: NoteRepository
    private let defaults: UserDefaults
    private let lastServerTimeKey = "sync.lastServerTime"

    private var isRunning = false

    public init(
        messages: MessageRepository = .shared,
        notes: NoteRepository = .shared,
        defaults: UserDefaults = AppGroup.userDefaults
    ) {
        self.messages = messages
        self.notes = notes
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

    /// Pushes local unsynced changes then pulls anything new from the server.
    /// Silently no-ops on auth/network errors so the UI still renders local data.
    public func run() async {
        guard !isRunning else { return }
        isRunning = true
        defer { isRunning = false }

        do {
            try await push()
            try await pull()
        } catch {
            // Intentionally swallowed — sync is best-effort.
        }
    }

    private func push() async throws {
        let unsyncedMessages = try messages.listUnsynced()
        let unsyncedNotes = try notes.listUnsynced()
        guard !unsyncedMessages.isEmpty || !unsyncedNotes.isEmpty else { return }

        let response = try await SyncAPI.push(messages: unsyncedMessages, notes: unsyncedNotes)
        let syncedAt = response.serverTime
        for dto in response.messages {
            try messages.upsert(dto.asMessage(syncedAt: syncedAt))
        }
        for dto in response.notes {
            try notes.upsert(dto.asNote(syncedAt: syncedAt))
        }
    }

    private func pull() async throws {
        let since = lastServerTime
        let response = try await SyncAPI.pull(since: since)
        for dto in response.messages {
            try messages.upsert(dto.asMessage(syncedAt: response.serverTime))
        }
        for dto in response.notes {
            try notes.upsert(dto.asNote(syncedAt: response.serverTime))
        }
        lastServerTime = response.serverTime
    }
}
