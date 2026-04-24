import Foundation
import Combine
import PrivoiceCore

@MainActor
final class VocabViewModel: ObservableObject {
    @Published private(set) var entries: [VocabEntry] = []
    @Published private(set) var isSyncing = false
    @Published var searchText: String = ""

    private let repository: VocabRepository
    private let syncCoordinator: SyncCoordinator

    init(
        repository: VocabRepository = .shared,
        syncCoordinator: SyncCoordinator = .shared
    ) {
        self.repository = repository
        self.syncCoordinator = syncCoordinator
    }

    var filteredEntries: [VocabEntry] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return entries }
        return entries.filter {
            $0.word.localizedCaseInsensitiveContains(trimmed)
            || ($0.phonetic ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    var totalCount: Int { entries.count }

    func reload() {
        do {
            entries = try repository.listActive()
        } catch {
            entries = []
        }
    }

    func sync() async {
        isSyncing = true
        await syncCoordinator.run()
        isSyncing = false
        reload()
    }

    func create(word: String, phonetic: String?) {
        let now = Date()
        let entry = VocabEntry(
            word: word,
            phonetic: phonetic,
            createdAt: now,
            updatedAt: now
        )
        try? repository.insert(entry)
        reload()
    }

    func update(_ entry: VocabEntry, word: String, phonetic: String?) {
        var updated = entry
        updated.word = word
        updated.phonetic = phonetic
        updated.updatedAt = Date()
        try? repository.update(updated)
        reload()
    }

    func delete(_ entry: VocabEntry) {
        try? repository.softDelete(clientId: entry.clientId)
        reload()
    }
}
