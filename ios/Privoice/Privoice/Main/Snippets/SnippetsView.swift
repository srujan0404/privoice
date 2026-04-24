import SwiftUI
import PrivoiceCore

struct SnippetsView: View {
    @StateObject private var viewModel = SnippetsViewModel()
    @State private var showNewSheet = false
    @State private var editing: Snippet?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScreenHeader(title: "Snippets")
                AppSearchField(text: $viewModel.searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, isEmpty ? 32 : 16)
                content
            }
            addButton
                .padding(.trailing, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .task {
            viewModel.reload()
            await viewModel.sync()
        }
        .sheet(isPresented: $showNewSheet) {
            NewSnippetView { trigger, expansion in
                viewModel.create(trigger: trigger, expansion: expansion)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editing) { snippet in
            NewSnippetView(existing: snippet) { trigger, expansion in
                viewModel.update(snippet, trigger: trigger, expansion: expansion)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var isEmpty: Bool {
        viewModel.snippets.isEmpty && viewModel.searchText.isEmpty
    }

    @ViewBuilder
    private var content: some View {
        if isEmpty {
            SnippetsEmptyView()
        } else {
            populatedList
        }
    }

    private var populatedList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                SectionTitle(text: "Your Snippets (\(viewModel.totalCount))")
                    .padding(.leading, 20)

                GroupedCard {
                    ForEach(Array(viewModel.filteredSnippets.enumerated()), id: \.element.id) { index, snippet in
                        Button(action: { editing = snippet }) {
                            SnippetRow(snippet: snippet)
                                .padding(.horizontal, 18)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.delete(snippet)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        if index < viewModel.filteredSnippets.count - 1 {
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
