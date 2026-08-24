import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            Picker("Appearance", selection: $settings.appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Section("Columns") {
                labeledSlider("Ideas", value: $settings.ideasShare)
                labeledSlider("Life", value: $settings.lifeShare)
                HStack {
                    Text("Work")
                    Spacer()
                    Text("\(Int((settings.workShare * 100).rounded()))%")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Button("Reset 37 / 37 / 26") {
                    settings.resetColumns()
                }
            }

            Section("Notes") {
                Text("Live outside the app at ~/Documents/Rebase. Git pulls and rebuilds cannot wipe them.")
                    .foregroundStyle(.secondary)
                Button("Open notes folder") {
                    NotesStore.revealInFinder()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 360)
        .padding()
    }

    private func labeledSlider(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
                .frame(width: 48, alignment: .leading)
            Slider(value: value, in: 0.20...0.50, step: 0.01)
            Text("\(Int((value.wrappedValue * 100).rounded()))%")
                .frame(width: 40, alignment: .trailing)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
