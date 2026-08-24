import AppKit
import SwiftUI

struct CaptureField: NSViewRepresentable {
    @Binding var text: String
    var onSubmit: () -> Void
    var ink: Color
    var muted: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField(string: text)
        field.isBordered = false
        field.drawsBackground = false
        field.isBezeled = false
        field.focusRingType = .none
        let base = NSFont.systemFont(ofSize: 16)
        if let serif = base.fontDescriptor.withDesign(.serif) {
            field.font = NSFont(descriptor: serif, size: 16)
        } else {
            field.font = base
        }
        applyColors(field)
        field.lineBreakMode = .byTruncatingTail
        field.delegate = context.coordinator
        field.target = context.coordinator
        field.action = #selector(Coordinator.submit(_:))
        DispatchQueue.main.async {
            field.window?.makeFirstResponder(field)
        }
        return field
    }

    func updateNSView(_ field: NSTextField, context: Context) {
        context.coordinator.onSubmit = onSubmit
        if field.stringValue != text {
            field.stringValue = text
        }
        applyColors(field)
    }

    private func applyColors(_ field: NSTextField) {
        field.textColor = NSColor(ink)
        let placeholderFont = field.font ?? NSFont.systemFont(ofSize: 16)
        field.placeholderAttributedString = NSAttributedString(
            string: "Write anything…",
            attributes: [
                .foregroundColor: NSColor(muted),
                .font: placeholderFont,
            ]
        )
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var text: Binding<String>
        var onSubmit: () -> Void

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self.text = text
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            text.wrappedValue = field.stringValue
        }

        @objc func submit(_ sender: Any?) {
            onSubmit()
        }
    }
}
