import SwiftUI

@MainActor
struct SettingsView: View {
    @Bindable var settings: AppSettings
    @Bindable var state: AppState
    @Bindable var updates: UpdateChecker
    @Environment(\.colorScheme) private var systemScheme

    private var palette: Palette {
        Palette.make(settings.colorScheme ?? systemScheme)
    }

    private var ideasShare: Binding<Double> {
        Binding(
            get: { settings.ideasShare },
            set: { settings.setIdeas($0) }
        )
    }

    private var lifeShare: Binding<Double> {
        Binding(
            get: { settings.lifeShare },
            set: { settings.setLife($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("REBASE")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(settings.accent.color)
                Spacer()
                Text("To-do list triage")
                    .font(.system(size: 11))
                    .foregroundStyle(palette.muted)
            }

            rule

            settingRow("APPEARANCE") {
                HStack(spacing: 2) {
                    ForEach(AppearanceMode.allCases) { mode in
                        appearanceButton(mode)
                    }
                }
            }

            settingRow("ACCENT") {
                HStack(spacing: 14) {
                    ForEach(Accent.allCases) { item in
                        accentButton(item)
                    }
                }
            }

            settingRow("BODY") {
                Slider(value: $settings.bodySize, in: AppSettings.minBody...AppSettings.maxBody, step: 1)
                    .frame(width: 210)
                Text("\(Int(settings.bodySize.rounded()))")
                    .monospacedDigit()
                    .frame(width: 28, alignment: .trailing)
                    .foregroundStyle(palette.muted)
            }

            rule

            settingRow("COLUMNS") {
                VStack(alignment: .leading, spacing: 8) {
                    labeledSlider("Ideas", value: ideasShare)
                    labeledSlider("Life", value: lifeShare)
                    HStack {
                        Text("Work")
                            .frame(width: 48, alignment: .leading)
                        Spacer()
                        Text("\(Int((settings.workShare * 100).rounded()))%")
                            .foregroundStyle(palette.muted)
                            .monospacedDigit()
                    }
                    Button("Reset 37 / 37 / 26") { settings.resetColumns() }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(settings.accent.color)
                        .buttonStyle(.plain)
                }
                .frame(width: 270)
            }

            rule

            settingRow("UPDATES") {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 8) {
                        Text(versionLabel)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(palette.muted)
                            .lineLimit(1)
                        Spacer(minLength: 12)
                        Toggle("At launch", isOn: $settings.checksForUpdatesAutomatically)
                            .toggleStyle(.switch)
                            .controlSize(.mini)
                            .font(.system(size: 10))
                    }

                    HStack(spacing: 7) {
                        Image(systemName: updates.symbolName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(updateStatusColor)
                            .symbolEffect(.rotate, options: .repeating, isActive: updates.isChecking)
                        Text(updates.message)
                            .font(.system(size: 11))
                            .foregroundStyle(palette.muted)
                            .lineLimit(2)
                    }

                    HStack(spacing: 7) {
                        actionButton(updates.isChecking ? "Checking…" : "Check now") {
                            Task { await updates.check() }
                        }
                        .disabled(updates.isChecking)
                        .opacity(updates.isChecking ? 0.62 : 1)

                        if let actionTitle = updates.actionTitle {
                            actionButton(actionTitle) {
                                updates.openAvailableUpdate()
                            }
                        }
                    }

                    Text("Checks GitHub only. It never writes to or replaces ~/Documents/Rebase.")
                        .font(.system(size: 10))
                        .foregroundStyle(palette.muted.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 330)
            }

            rule

            settingRow("FILES") {
                VStack(alignment: .leading, spacing: 9) {
                    Text("~/Documents/Rebase  ·  days.json + rebase.md")
                        .font(.system(size: 11))
                        .foregroundStyle(palette.muted)
                    HStack(spacing: 7) {
                        actionButton("Open folder") { NotesStore.revealInFinder() }
                        actionButton("Export") { NotesStore.exportMarkdown(state.days) }
                        actionButton("Import") {
                            if let imported = NotesStore.importMarkdown() {
                                state.applyMarkdown(imported)
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 575, height: 570)
        .foregroundStyle(palette.ink)
        .tint(settings.accent.color)
        .background { palette.paper.ignoresSafeArea() }
        .preferredColorScheme(settings.colorScheme)
    }

    private var versionLabel: String {
        let commit = updates.currentCommit
        if commit == "unknown" {
            return "v\(updates.currentVersion)"
        }
        return "v\(updates.currentVersion) · \(String(commit.prefix(7)))"
    }

    private var updateStatusColor: Color {
        switch updates.status {
        case .releaseAvailable, .sourceAvailable:
            settings.accent.color
        case .failed:
            Theme.star
        case .current:
            palette.ink.opacity(0.72)
        default:
            palette.muted
        }
    }

    private var rule: some View {
        Rectangle()
            .fill(settings.accent.color.opacity(0.30))
            .frame(height: 1)
    }

    private func settingRow<Content: View>(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(palette.muted)
                .frame(width: 86, alignment: .leading)
            content()
            Spacer(minLength: 0)
        }
    }

    private func appearanceButton(_ mode: AppearanceMode) -> some View {
        let selected = settings.appearance == mode
        return Button {
            settings.appearance = mode
        } label: {
            Text(mode.title)
                .font(.system(size: 11, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? settings.accent.color : palette.muted)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(selected ? settings.accent.color.opacity(0.12) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func accentButton(_ item: Accent) -> some View {
        let selected = settings.accent == item
        return Button {
            settings.accent = item
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(item.color)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle()
                            .stroke(palette.ink.opacity(selected ? 0.9 : 0.15), lineWidth: selected ? 2 : 1)
                    }
                Text(item.title)
                    .font(.system(size: 9, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? item.color : palette.muted)
            }
        }
        .buttonStyle(.plain)
        .help(item.title)
    }

    private func labeledSlider(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title).frame(width: 48, alignment: .leading)
            Slider(value: value, in: 0.20...0.50, step: 0.01)
            Text("\(Int((value.wrappedValue * 100).rounded()))%")
                .frame(width: 40, alignment: .trailing)
                .monospacedDigit()
                .foregroundStyle(palette.muted)
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(settings.accent.color)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(settings.accent.color.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(settings.accent.color.opacity(0.28), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
