import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(AppGroup.Key.username, store: AppGroup.defaults) private var username = ""
    @AppStorage(AppGroup.Key.range, store: AppGroup.defaults) private var range = HistoryRange.year.rawValue

    var body: some View {
        Form {
            TextField("LeetCode username", text: $username)
                .textFieldStyle(.roundedBorder)

            Picker("History", selection: $range) {
                ForEach(HistoryRange.allCases) { r in
                    Text(r.label).tag(r.rawValue)
                }
            }

            Button("Refresh Widget Now") {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .padding()
        .onChange(of: username) { _, _ in WidgetCenter.shared.reloadAllTimelines() }
        .onChange(of: range) { _, _ in WidgetCenter.shared.reloadAllTimelines() }
    }
}
