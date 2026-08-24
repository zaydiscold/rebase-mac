import SwiftUI

struct EntryRowView: View {
    let entry: PrototypeEntry
    var onToggle: (() -> Void)?
    var onStar: (() -> Void)?
    @Environment(\.palette) private var palette
    @Environment(\.bodySize) private var bodySize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            leadingMark
            Text(entry.body)
                .font(.system(size: bodySize, weight: .regular, design: .serif))
                .foregroundStyle(entry.done ? palette.muted : palette.ink)
                .strikethrough(entry.done, color: palette.muted.opacity(0.8))
                .lineLimit(entry.done ? 1 : nil)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: !entry.done)
                .frame(maxWidth: .infinity, alignment: .leading)
            starButton
        }
        .padding(.vertical, entry.done ? 2 : 4)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { onToggle?() }
        .animation(reduceMotion ? nil : Theme.motion, value: entry.done)
        .opacity(entry.done ? 0.72 : 1)
    }

    private var starButton: some View {
        Button {
            onStar?()
        } label: {
            Image(systemName: "asterisk")
                .font(.system(size: 9, weight: entry.important ? .black : .bold))
                .foregroundStyle(entry.done ? palette.muted.opacity(0.6) : Theme.star)
                .frame(width: 12, height: 12, alignment: .center)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(entry.done ? "Completed" : "Mark important")
        .accessibilityLabel(entry.done ? "Completed" : "Open task")
    }


    private var leadingMark: some View {
        Button {
            onToggle?()
        } label: {
            Image(systemName: entry.done ? "checkmark.square" : "square")
                .font(.system(size: max(11, bodySize * 0.72), weight: .regular))
                .foregroundStyle(palette.muted)
        }
        .buttonStyle(.plain)
        .help(entry.done ? "Mark open" : "Mark done")
    }
}
