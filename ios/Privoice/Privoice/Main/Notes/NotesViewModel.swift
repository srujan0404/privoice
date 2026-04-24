import Foundation
import Combine
import PrivoiceCore

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published private(set) var isSyncing = false
    @Published var searchText: String = ""

    private let repository: NoteRepository
    private let syncCoordinator: SyncCoordinator

    init(
        repository: NoteRepository = .shared,
        syncCoordinator: SyncCoordinator = .shared
    ) {
        self.repository = repository
        self.syncCoordinator = syncCoordinator
    }

    var filteredNotes: [Note] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return notes }
        return notes.filter {
            $0.displayTitle.localizedCaseInsensitiveContains(trimmed)
            || $0.body.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var groupedSections: [(title: String, items: [Note])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"

        var groups: [(key: Date, title: String, items: [Note])] = []
        var indexByKey: [Date: Int] = [:]

        for note in filteredNotes {
            let dayStart = calendar.startOfDay(for: note.updatedAt)
            let title: String
            if dayStart == today { title = "Today" }
            else if dayStart == yesterday { title = "Yesterday" }
            else { title = df.string(from: dayStart) }

            if let idx = indexByKey[dayStart] {
                groups[idx].items.append(note)
            } else {
                indexByKey[dayStart] = groups.count
                groups.append((key: dayStart, title: title, items: [note]))
            }
        }

        return groups
            .sorted { $0.key > $1.key }
            .map { (title: $0.title, items: $0.items) }
    }

    func reload() {
        do {
            notes = try repository.listActive()
        } catch {
            notes = []
        }
    }

    func sync() async {
        isSyncing = true
        await syncCoordinator.run()
        isSyncing = false
        reload()
    }

    func createEmptyNote() -> Note {
        let now = Date()
        let note = Note(title: "", body: "", createdAt: now, updatedAt: now)
        try? repository.insert(note)
        reload()
        return note
    }

    func save(_ note: Note) {
        var updated = note
        updated.updatedAt = Date()
        try? repository.update(updated)
        reload()
    }

    func delete(_ note: Note) {
        try? repository.softDelete(clientId: note.clientId)
        reload()
    }
}
