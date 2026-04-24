import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("History", systemImage: "paperplane") }
            .tag(0)

            NavigationStack {
                NotesView()
            }
            .tabItem { Label("Notes", systemImage: "doc.text") }
            .tag(1)

            NavigationStack {
                VocabPlaceholder().navigationTitle("Vocab")
            }
            .tabItem { Label("Vocab", systemImage: "character.book.closed") }
            .tag(2)

            NavigationStack {
                SnippetsPlaceholder().navigationTitle("Snippets")
            }
            .tabItem { Label("Snippets", systemImage: "scissors") }
            .tag(3)

            NavigationStack {
                ToneView()
            }
            .tabItem { Label("Tone", systemImage: "face.smiling") }
            .tag(4)
        }
    }
}
