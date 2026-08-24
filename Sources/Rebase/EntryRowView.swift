import SwiftUI

struct EntryRowView: View {
    let entry: PrototypeEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if entry.isTask {
                Image(systemName: entry.done ? "checkmark.square" : "square")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Theme.muted)
                    .offset(y: 1)
            }
            Text(entry.body)
                .font(Theme.bodyFont)
                .foregroundStyle(entry.done ? Theme.muted : Theme.ink)
                .strikethrough(entry.done, color: Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
    }
}
