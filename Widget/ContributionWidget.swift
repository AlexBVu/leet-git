import WidgetKit
import SwiftUI
import AppIntents

/// Widget configuration shown in the native "Edit Widget" panel.
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "LeetCode Activity" }
    static var description: IntentDescription {
        IntentDescription("Your LeetCode submissions as a contribution graph.")
    }

    @Parameter(title: "LeetCode Username", default: "SlowPanda")
    var username: String

    @Parameter(title: "History", default: .year)
    var range: HistoryRange
}

struct ContributionEntry: TimelineEntry {
    let date: Date
    let grid: ContributionGrid
    let username: String
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ContributionEntry {
        ContributionEntry(date: Date(), grid: ContributionGrid.build(counts: [:], days: 365), username: "")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ContributionEntry {
        ContributionEntry(
            date: Date(),
            grid: ContributionGrid.build(counts: [:], days: configuration.range.days),
            username: configuration.username
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ContributionEntry> {
        let counts = await LeetCodeAPI.fetchCalendar(username: configuration.username)
        let grid = ContributionGrid.build(counts: counts, days: configuration.range.days)
        let entry = ContributionEntry(date: Date(), grid: grid, username: configuration.username)

        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        return Timeline(entries: [entry], policy: .after(next))
    }
}

@main
struct ContributionWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "LeetGitWidget", intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ContributionGridView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("LeetCode Activity")
        .description("Your LeetCode submissions as a contribution graph.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
