import SwiftUI
import PrivoiceCore

struct ToneView: View {
    @State private var selectedTone: Tone = TonePreference.shared.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("General Tone Preferences")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Pocket voice sounds like this everywhere.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

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
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Tone")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { avatar }
        }
    }

    private var avatar: some View {
        Circle()
            .fill(Color(.systemGray4))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            )
    }

    private func selectTone(_ tone: Tone) {
        selectedTone = tone
        TonePreference.shared.current = tone
    }
}
