import SwiftUI

/// Yellow sticky-note thumbnail with wavy lines, matching the Figma empty-state + list-row art.
struct NoteThumbnail: View {
    var size: CGFloat = 56

    var body: some View {
        let paper = Color(red: 0.99, green: 0.92, blue: 0.63)
        RoundedRectangle(cornerRadius: size * 0.22)
            .fill(paper)
            .frame(width: size, height: size * 1.1)
            .overlay(waves.foregroundStyle(paper.opacity(0.0).blended()))
    }

    private var waves: some View {
        Canvas { context, rect in
            let ink = Color(red: 0.92, green: 0.82, blue: 0.47)
            let amp = rect.height * 0.04
            let spacing = rect.height * 0.17
            let startY = rect.height * 0.38
            let margin = rect.width * 0.18
            let endX = rect.width - margin
            var path = Path()
            for i in 0..<3 {
                let y = startY + CGFloat(i) * spacing
                path.move(to: CGPoint(x: margin, y: y))
                path.addCurve(
                    to: CGPoint(x: endX, y: y),
                    control1: CGPoint(x: margin + (endX - margin) * 0.33, y: y - amp),
                    control2: CGPoint(x: margin + (endX - margin) * 0.66, y: y + amp)
                )
            }
            context.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
        }
    }
}

private extension Color {
    func blended() -> Color { self }
}
