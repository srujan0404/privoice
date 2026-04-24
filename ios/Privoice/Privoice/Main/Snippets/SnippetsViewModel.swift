import Foundation
import Combine
import PrivoiceCore

@MainActor
final class SnippetsViewModel: ObservableObject {
    @Published private(set) var snippets: [Snippet] = []
    @Published private(set) var isSyncing = false
    @Published var searchText: String = ""

    private let repository: SnippetRepository
    private let syncCoordinator: SyncCoordinator

    init(
        repository: SnippetRepository = .shared,
        syncCoordinator: SyncCoordinator = .shared
    ) {
        self.repository = repository
        self.syncCoordinator = syncCoordinator
    }

    var filteredSnippets: [Snippet] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return snippets }
        return snippets.filter {
            $0.trigger.localizedCaseInsensitiveContains(trimmed)
            || $0.expansion.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var totalCount: Int { snippets.count }

    func reload() {
        do {
            snippets = try repository.listActive()
        } catch {
            snippets = []
        }
    }

    func sync() async {
        isSyncing = true
        await syncCoordinator.run()
        isSyncing = false
        reload()
    }

    func create(trigger: String, expansion: String) {
        let now = Date()
        let snippet = Snippet(
            trigger: trigger,
            expansion: expansion,
            createdAt: now,
            updatedAt: now
        )
        try? repository.insert(snippet)
        reload()
    }

    func update(_ snippet: Snippet, trigger: String, expansion: String) {
        var updated = snippet
        updated.trigger = trigger
        updated.expansion = expansion
        updated.updatedAt = Date()
        try? repository.update(updated)
        reload()
    }

    func delete(_ snippet: Snippet) {
        try? repository.softDelete(clientId: snippet.clientId)
        reload()
    }
}
