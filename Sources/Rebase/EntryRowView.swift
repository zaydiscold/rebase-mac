import SwiftUI

struct EntryRowView: View {
    let entry: PrototypeEntry
    var onToggle: (() -> Void)?
    var onStar: (() -> Void)?
    var onEdit: ((String) -> Void)?
    @State private var editing = false
    @State private var editDraft = ""
    @FocusState private var editFocused: Bool
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent
    @Environment(\.bodySize) private var bodySize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            leadingMark
            entryContent
            starButton
        }
        .padding(.vertical, entry.done ? 2 : 4)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .background(editing ? accent.color.opacity(0.055) : Color.clear)
        .contextMenu {
            if !editing, onEdit != nil {
                Button("Edit") {
                    beginEditing()
                }
            }
        }
        .animation(reduceMotion ? nil : Theme.motion, value: entry.done)
        .animation(reduceMotion ? nil : Theme.motion, value: editing)
        .opacity(entry.done && !editing ? 0.72 : 1)
    }

    @ViewBuilder
    private var entryContent: some View {
        if editing {
            TextField("Edit entry", text: $editDraft)
                .textFieldStyle(.plain)
                .font(.system(size: bodySize, weight: .regular, design: .serif))
                .foregroundStyle(palette.ink)
                .focused($editFocused)
                .onSubmit { commitEdit() }
                .onExitCommand { cancelEdit() }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(accent.color.opacity(0.68))
                        .frame(height: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .help("Return saves. Escape cancels.")
        } else {
            Text(entry.body)
                .font(.system(size: bodySize, weight: .regular, design: .serif))
                .foregroundStyle(entry.done ? palette.muted : palette.ink)
                .strikethrough(entry.done, color: palette.muted.opacity(0.8))
                .lineLimit(entry.done ? 1 : nil)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: !entry.done)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { beginEditing() }
                .help(onEdit == nil ? entry.body : "Double-click or right-click to edit")
        }
    }

    private var starButton: some View {
        Button {
            onStar?()
        } label: {
            Image(systemName: "asterisk")
                .font(.system(size: 9, weight: entry.important ? .black : .bold))
                .foregroundStyle(
                    entry.important
                        ? Theme.star
                        : palette.muted.opacity(entry.done ? 0.35 : 0.45)
                )
                .frame(width: 12, height: 12, alignment: .center)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(entry.important ? "Remove importance" : "Mark important")
        .accessibilityLabel(entry.important ? "Important task" : "Normal task")
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

    private func beginEditing() {
        guard onEdit != nil else { return }
        editDraft = entry.body
        editing = true
        DispatchQueue.main.async {
            editFocused = true
        }
    }

    private func commitEdit() {
        let cleaned = editDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            cancelEdit()
            return
        }

        editFocused = false
        editing = false
        if cleaned != entry.body {
            onEdit?(cleaned)
        }
    }

    private func cancelEdit() {
        editFocused = false
        editDraft = entry.body
        editing = false
    }
}
