import SwiftUI

struct EntryRowView: View {
    let entry: PrototypeEntry
    var onToggle: (() -> Void)?
    var onStar: (() -> Void)?
    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            leadingMark
            Text(entry.body)
                .font(Theme.bodyFont)
                .foregroundStyle(entry.done ? palette.muted : palette.ink)
                .strikethrough(entry.done, color: palette.muted.opacity(0.8))
                .lineLimit(entry.done ? 1 : nil)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: !entry.done)
            Spacer(minLength: 8)
            Button {
                onStar?()
            } label: {
                Text("∗")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(entry.important ? Theme.star : palette.muted.opacity(0.28))
                    .frame(width: 16, height: 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(entry.important ? "Clear today-important" : "Mark important for the day")
        }
        .padding(.vertical, entry.done ? 2 : 4)
        .padding(.horizontal, 16)
        .animation(reduceMotion ? nil : Theme.motion, value: entry.done)
        .animation(reduceMotion ? nil : Theme.motion, value: entry.important)
        .opacity(entry.done ? 0.72 : 1)
    }

    @ViewBuilder
    private var leadingMark: some View {
        if entry.isTask {
            Button {
                onToggle?()
            } label: {
                Image(systemName: entry.done ? "checkmark.square" : "square")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(palette.muted)
            }
            .buttonStyle(.plain)
            .help(entry.done ? "Mark open" : "Mark done")
        } else {
            Circle()
                .fill(palette.muted.opacity(0.85))
                .frame(width: 4, height: 4)
                .offset(y: -1)
                .frame(width: 11)
        }
    }
}
