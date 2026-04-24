import SwiftUI
import PrivoiceCore

struct VocabView: View {
    @StateObject private var viewModel = VocabViewModel()
    @State private var showNewSheet = false
    @State private var editing: VocabEntry?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScreenHeader(title: "Vocabulary")
                    .padding(.bottom, isEmpty ? 32 : 16)
                content
            }
            addButton
                .padding(.trailing, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.reload()
            await viewModel.sync()
        }
        .sheet(isPresented: $showNewSheet) {
            NewVocabView { word, phonetic in
                viewModel.create(word: word, phonetic: phonetic)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editing) { entry in
            NewVocabView(existing: entry) { word, phonetic in
                viewModel.update(entry, word: word, phonetic: phonetic)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var isEmpty: Bool {
        viewModel.entries.isEmpty
    }

    @ViewBuilder
    private var content: some View {
        if isEmpty {
            emptyState
        } else {
            populatedList
        }
    }

    private var populatedList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                SectionTitle(text: "Your Words (\(viewModel.totalCount))")
                    .padding(.leading, 20)

                GroupedCard {
                    ForEach(Array(viewModel.filteredEntries.enumerated()), id: \.element.id) { index, entry in
                        Button(action: { editing = entry }) {
                            VocabRow(entry: entry)
                                .padding(.horizontal, 18)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.delete(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        if index < viewModel.filteredEntries.count - 1 {
                            CardDivider()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 120)
        }
        .refreshable { await viewModel.sync() }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 120)
            Image(systemName: "character.book.closed")
                .font(.system(size: 52, weight: .regular, design: .rounded))
                .foregroundStyle(Color.accentColor.opacity(0.7))
            Text("No words, yet")
                .font(AppFont.semibold(20))
            Text("Teach Privoice names and terms it should recognize.")
                .font(AppFont.regular(15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addButton: some View {
        Button(action: { showNewSheet = true }) {
            Image(systemName: "plus")
                .font(AppFont.bold(24))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(Color.accentColor, in: .circle)
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}
