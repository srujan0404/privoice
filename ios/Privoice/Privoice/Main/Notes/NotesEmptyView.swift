import SwiftUI

struct NotesEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Top breathing room — pushes the stack+title block into the upper-mid of the screen
            Spacer().frame(minHeight: 60, maxHeight: 120)

            Image("NotesStack")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 120)

            Text("No notes, yet")
                .font(AppFont.semibold(20))
                .tracking(-0.4)
                .foregroundStyle(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                .padding(.top, 14)

            Text("Start writing your first note")
                .font(AppFont.regular(15))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            // Gap between copy and arrow
            Spacer().frame(minHeight: 48)

            // Arrow aligned right-of-center so its head points toward the FAB
            HStack(spacing: 0) {
                Spacer()
                Image("NotesArrow")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90)
                    .padding(.trailing, 100)
            }

            // Leave room for FAB + tab bar
            Spacer().frame(minHeight: 140)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
