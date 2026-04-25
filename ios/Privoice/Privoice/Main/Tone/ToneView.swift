import SwiftUI
import PrivoiceCore

struct ToneView: View {
    @State private var selectedTone: Tone = TonePreference.shared.current

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: "Tone")
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("General Tone Preferences")
                            .font(AppFont.semibold(17))
                        Text("Privoice sounds like this everywhere.")
                            .font(AppFont.regular(14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Tone.allCases) { tone in
                                ToneCardView(
                                    tone: tone,
                                    isSelected: selectedTone == tone,
                                    onTap: { selectTone(tone) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func selectTone(_ tone: Tone) {
        selectedTone = tone
        TonePreference.shared.current = tone
    }
}
