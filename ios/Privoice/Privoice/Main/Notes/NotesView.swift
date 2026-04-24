import SwiftUI
import PrivoiceCore

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var activeNote: Note?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if viewModel.notes.isEmpty && viewModel.searchText.isEmpty {
                    NotesEmptyView()
                } else {
                    list
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")

            addButton
                .padding(.trailing, 20)
                .padding(.bottom, 20)
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { avatar }
        }
        .task {
            viewModel.reload()
            await viewModel.sync()
        }
        .refreshable {
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

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.groupedSections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                        VStack(spacing: 0) {
                            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, note in
                                Button(action: { activeNote = note }) {
                                    NoteRow(note: note)
                                }
                                .buttonStyle(.plain)
                                if index < section.items.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    private var addButton: some View {
        Button(action: {
            let note = viewModel.createEmptyNote()
            activeNote = note
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
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

    private var avatar: some View {
        Menu {
            SignOutButton()
        } label: {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                )
        }
    }
}
