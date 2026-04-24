import SwiftUI
import PrivoiceCore

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "History")
            AppSearchField(text: $viewModel.searchText)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 12)
            content
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.reload()
            await viewModel.sync()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.messages.isEmpty && viewModel.searchText.isEmpty {
            HistoryEmptyView()
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
                            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, message in
                                HistoryRow(message: message)
                                    .padding(.horizontal, 16)
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
}
