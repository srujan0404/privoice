import SwiftUI

struct WaveformView: View {
    let level: Float

    private let barCount = 7
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 3
    private let maxHeight: CGFloat = 24

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.accentColor)
                    .frame(width: barWidth, height: heightFor(index: i))
            }
        }
        .frame(height: maxHeight)
        .animation(.easeOut(duration: 0.15), value: level)
    }

    private func heightFor(index: Int) -> CGFloat {
        let midDistance = abs(Double(index) - Double(barCount - 1) / 2)
        let falloff = 1.0 - (midDistance / Double(barCount))
        let scaled = CGFloat(Double(level) * falloff)
        return max(4, maxHeight * scaled)
    }
}

#Preview {
    WaveformView(level: 0.6)
        .padding()
}
