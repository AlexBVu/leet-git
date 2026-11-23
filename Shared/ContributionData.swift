import Foundation

struct Day: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }

    /// GitHub-style 0...4 intensity.
    /// ponytail: fixed thresholds; tune here if your submission volume differs.
    var level: Int {
        switch count {
        case 0: return 0
        case 1: return 1
        case 2...3: return 2
        case 4...6: return 3
        default: return 4
        }
    }
}

struct MonthLabel: Identifiable {
    let column: Int
    let name: String
    var id: Int { column }
}

struct ContributionGrid {
    let weeks: [[Day]]           // columns, each 7 days (Sun...Sat, top to bottom)

    /// GitHub-style grid of exactly `weekCount` Sunday-start columns, the last
    /// of which is the current (partial) week.
    ///
    /// Counted in weeks, not days, because a day count snapped to week
    /// boundaries yields a column count that swings by one with today's weekday.
    static func build(counts: [Date: Int], weeks weekCount: Int, today: Date = Date()) -> ContributionGrid {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday
        let end = cal.startOfDay(for: today)
        let thisWeek = cal.dateInterval(of: .weekOfYear, for: end)?.start ?? end
        let start = cal.date(byAdding: .weekOfYear, value: -(weekCount - 1), to: thisWeek) ?? thisWeek

        var weeks: [[Day]] = []
        var cursor = start
        while cursor <= end {
            var week: [Day] = []
            for _ in 0..<7 {
                // Stop at today — days that haven't happened get no cell at all,
                // so the current week is a short column like GitHub's.
                guard cursor <= end else { break }
                week.append(Day(date: cursor, count: counts[cursor] ?? 0))
                cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor.addingTimeInterval(86400)
            }
            weeks.append(week)
        }
        return ContributionGrid(weeks: weeks)
    }
}

#if DEBUG
/// ponytail: one runnable check — grid shape + level bucketing.
enum ContributionDataCheck {
    static func run() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date(timeIntervalSince1970: 1_767_398_400))
        let counts = [today: 5]
        let grid = ContributionGrid.build(counts: counts, weeks: 52, today: today)
        assert(grid.weeks.last?.contains { $0.date == today && $0.count == 5 } == true, "today's count lands")

        // Walk a whole week of possible "today"s: the column count must not move
        // with the weekday, and no cell may sit in the future.
        for offset in 0..<7 {
            let day = cal.date(byAdding: .day, value: offset, to: today) ?? today
            let g = ContributionGrid.build(counts: [:], weeks: 4, today: day)
            assert(g.weeks.count == 4, "exactly 4 columns whatever the weekday")
            assert(g.weeks.dropLast().allSatisfy { $0.count == 7 }, "only the last column may be short")
            assert(g.weeks.last?.last?.date == day, "grid ends on today — no future cells")
            assert(g.weeks.last?.count == cal.component(.weekday, from: day), "Sunday...today")
        }
        assert(Day(date: today, count: 0).level == 0)
        assert(Day(date: today, count: 1).level == 1)
        assert(Day(date: today, count: 3).level == 2)
        assert(Day(date: today, count: 6).level == 3)
        assert(Day(date: today, count: 99).level == 4)
    }
}
#endif
