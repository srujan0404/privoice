import SwiftUI
import PrivoiceCore

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var activeNote: Note?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScreenHeader(title: "Notes")
                AppSearchField(text: $viewModel.searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                content
            }
            addButton
                .padding(.trailing, 20)
                .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.reload()
            await viewModel.sync()
        }
        .navigationDestination(item: $activeNote) { note in
            NoteDetailView(
                note: note,
                onSave: { viewModel.save($0) },
                onDelete: { viewModel.delete($0) }
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.notes.isEmpty && viewModel.searchText.isEmpty {
            NotesEmptyView()
        } else {
            populatedList
        }
    }

    private var populatedList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                ForEach(viewModel.groupedSections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(section.title)
                            .font(AppFont.semibold(15))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.leading, 20)

                        GroupedCard {
                            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, note in
                                Button(action: { activeNote = note }) {
                                    NoteRow(note: note)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(.plain)
                                if index < section.items.count - 1 {
                                    CardDivider()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 120)
        }
        .refreshable { await viewModel.sync() }
    }

    private var addButton: some View {
        Button(action: {
            let note = viewModel.createEmptyNote()
            activeNote = note
        }) {
            Image(systemName: "plus")
                .font(AppFont.bold(24))
                .foregroundStyle(Color.accentColor)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 1.2, dash: [4, 4]))
                )
        }
        .buttonStyle(.plain)
    }
}
