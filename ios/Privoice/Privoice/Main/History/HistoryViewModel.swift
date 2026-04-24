import Foundation
import Combine
import PrivoiceCore

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var isSyncing = false
    @Published var searchText: String = ""

    private let repository: MessageRepository
    private let syncCoordinator: SyncCoordinator

    init(
        repository: MessageRepository = .shared,
        syncCoordinator: SyncCoordinator = .shared
    ) {
        self.repository = repository
        self.syncCoordinator = syncCoordinator
    }

    /// Messages after applying search filter, still newest-first.
    var filteredMessages: [Message] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return messages }
        return messages.filter {
            $0.polishedText.localizedCaseInsensitiveContains(trimmed)
        }
    }

    /// Filtered messages grouped by calendar-relative section (Today, Yesterday, formatted date).
    /// Sections are returned in descending date order.
    var groupedSections: [(title: String, items: [Message])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"

        var groups: [(key: Date, title: String, items: [Message])] = []
        var indexByKey: [Date: Int] = [:]

        for message in filteredMessages {
            let dayStart = calendar.startOfDay(for: message.createdAt)
            let title: String
            if dayStart == today { title = "Today" }
            else if dayStart == yesterday { title = "Yesterday" }
            else { title = df.string(from: dayStart) }

            if let idx = indexByKey[dayStart] {
                groups[idx].items.append(message)
            } else {
                indexByKey[dayStart] = groups.count
                groups.append((key: dayStart, title: title, items: [message]))
            }
        }

        return groups
            .sorted { $0.key > $1.key }
            .map { (title: $0.title, items: $0.items) }
    }

    func reload() {
        do {
            messages = try repository.listActive()
        } catch {
            messages = []
        }
    }

    func sync() async {
        isSyncing = true
        await syncCoordinator.run()
        isSyncing = false
        reload()
    }
}
