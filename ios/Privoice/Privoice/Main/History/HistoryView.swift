import SwiftUI
import PrivoiceCore

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        Group {
            if viewModel.messages.isEmpty && viewModel.searchText.isEmpty {
                HistoryEmptyView()
            } else {
                list
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        .navigationTitle("History")
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
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18, pinnedViews: []) {
                ForEach(viewModel.groupedSections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(section.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                        VStack(spacing: 10) {
                            ForEach(section.items) { message in
                                HistoryRow(message: message)
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
