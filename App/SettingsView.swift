import SwiftUI

/// The widget extension needs a host app to ship in; this is it. Configuration
/// lives on the widget itself (right-click → Edit Widget), so this is just a
/// pointer to that.
struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LeetGit")
                .font(.title2).bold()
            Text("Add the **LeetCode Activity** widget to your desktop or Notification Center, then right-click it and choose **Edit Widget** to set your LeetCode username and history range.")
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
