import SwiftUI

@main
struct LeetGitApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView()
                .frame(width: 360, height: 180)
        }
        .windowResizability(.contentSize)
    }
}
