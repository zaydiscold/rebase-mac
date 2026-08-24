import SwiftUI

struct LaneColumnView: View {
    let entries: [PrototypeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entries.isEmpty {
                Color.clear.frame(height: 12)
            } else {
                ForEach(entries) { entry in
                    EntryRowView(entry: entry)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
