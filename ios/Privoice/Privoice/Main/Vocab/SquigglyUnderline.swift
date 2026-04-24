import SwiftUI

/// Draws a red spellcheck-style squiggle. Used to decorate user-added vocab
/// words the way iOS underlines unknown words in a TextField.
struct SquigglyUnderline: Shape {
    var wavelength: CGFloat = 4
    var amplitude: CGFloat = 1.3

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0 else { return path }
        let y = rect.midY
        path.move(to: CGPoint(x: 0, y: y))
        var x: CGFloat = 0
        var up = true
        while x < rect.width {
            let next = min(x + wavelength, rect.width)
            path.addQuadCurve(
                to: CGPoint(x: next, y: y),
                control: CGPoint(x: x + wavelength / 2, y: y + (up ? -amplitude : amplitude))
            )
            x = next
            up.toggle()
        }
        return path
    }
}

/// Text with a red wavy underline, used for vocab words.
struct UnderlinedWord: View {
    let text: String
    var font: Font = .system(size: 17)

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(.primary)
            .overlay(alignment: .bottom) {
                SquigglyUnderline()
                    .stroke(Color.red, lineWidth: 1.1)
                    .frame(height: 3)
                    .offset(y: 4)
            }
    }
}
