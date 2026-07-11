import WidgetKit
import SwiftUI

struct ContributionEntry: TimelineEntry {
    let date: Date
    let grid: ContributionGrid
    let username: String
}

struct Provider: TimelineProvider {
    private func emptyEntry(username: String = "") -> ContributionEntry {
        ContributionEntry(
            date: Date(),
            grid: ContributionGrid.build(counts: [:], days: AppGroup.range.days),
            username: username
        )
    }

    func placeholder(in context: Context) -> ContributionEntry { emptyEntry() }

    func getSnapshot(in context: Context, completion: @escaping (ContributionEntry) -> Void) {
        completion(emptyEntry(username: AppGroup.username))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ContributionEntry>) -> Void) {
        Task {
            let username = AppGroup.username
            let range = AppGroup.range
            let counts = await LeetCodeAPI.fetchCalendar(username: username)
            let grid = ContributionGrid.build(counts: counts, days: range.days)
            let entry = ContributionEntry(date: Date(), grid: grid, username: username)

            let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }
}

@main
struct ContributionWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LeetGitWidget", provider: Provider()) { entry in
            ContributionGridView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("LeetCode Activity")
        .description("Your LeetCode submissions as a contribution graph.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
