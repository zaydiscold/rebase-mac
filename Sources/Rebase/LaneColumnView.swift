import SwiftUI

struct LaneColumnView: View {
    let entries: [PrototypeEntry]
    var lane: Lane
    var dayId: String
    var onToggle: ((String, Lane, String) -> Void)?
    var onStar: ((String, Lane, String) -> Void)?
    var onEdit: ((String, Lane, String, String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entries.isEmpty {
                Color.clear.frame(height: 4)
            } else {
                ForEach(entries) { entry in
                    EntryRowView(
                        entry: entry,
                        onToggle: { onToggle?(dayId, lane, entry.id) },
                        onStar: { onStar?(dayId, lane, entry.id) },
                        onEdit: { body in onEdit?(dayId, lane, entry.id, body) }
                    )
                    .transition(.opacity.combined(with: .offset(y: -4)))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
