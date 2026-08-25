import SwiftUI

struct TimelineView: View {
    @Bindable var state: AppState
    @Environment(\.palette) private var palette

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: 1)
                        .id("top")
                    ForEach(state.monthSections) { section in
                        if section.id != state.currentMonthKey {
                            MonthHeaderView(
                                section: section,
                                expanded: state.isMonthExpanded(section.id),
                                onToggle: { state.toggleMonth(section.id) }
                            )
                            .id("month-\(section.id)")
                        }
                        if section.id == state.currentMonthKey || state.isMonthExpanded(section.id) {
                            ForEach(section.days) { day in
                                DaySectionView(
                                    day: day,
                                    expanded: state.isDayExpanded(day.id),
                                    onToggleDay: { state.toggleDay(day.id) },
                                    onToggle: { dayId, lane, entryId in
                                        state.toggleDone(dayId: dayId, lane: lane, entryId: entryId)
                                    },
                                    onStar: { dayId, lane, entryId in
                                        state.toggleImportant(dayId: dayId, lane: lane, entryId: entryId)
                                    },
                                    onEdit: { dayId, lane, entryId, body in
                                        state.editEntry(dayId: dayId, lane: lane, entryId: entryId, body: body)
                                    }
                                )
                                .id(day.id)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .animation(Theme.motion, value: captureFingerprint)
            }
            .scrollIndicators(.hidden)
            .background(palette.paper)
            .onPreferenceChange(DayFrameKey.self) { frames in
                state.dayFrames = frames
            }
            .onScrollGeometryChange(for: CGRect.self) { geometry in
                geometry.visibleRect
            } action: { _, newValue in
                state.visibleRect = newValue
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: captureFingerprint) {
                proxy.scrollTo("top", anchor: .top)
            }
        }
    }

    private var captureFingerprint: String {
        let today = state.days.first
        return "\(today?.ideas.count ?? 0)-\(today?.life.count ?? 0)-\(today?.work.count ?? 0)"
    }
}
