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

    /// GitHub-style grid ending today, covering `days` back, snapped to whole
    /// weeks that start on Sunday.
    static func build(counts: [Date: Int], days: Int, today: Date = Date()) -> ContributionGrid {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday
        let end = cal.startOfDay(for: today)
        let rawStart = cal.date(byAdding: .day, value: -(days - 1), to: end) ?? end
        let start = cal.dateInterval(of: .weekOfYear, for: rawStart)?.start ?? rawStart

        var weeks: [[Day]] = []
        var cursor = start
        while cursor <= end {
            var week: [Day] = []
            for _ in 0..<7 {
                // Future days of the current week render as empty (count 0).
                let count = cursor <= end ? (counts[cursor] ?? 0) : 0
                week.append(Day(date: cursor, count: count))
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
        let grid = ContributionGrid.build(counts: counts, days: 365, today: today)
        assert(grid.weeks.allSatisfy { $0.count == 7 }, "every column must have 7 days")
        assert(grid.weeks.last?.contains { $0.date == today } == true, "today in last week")
        assert(Day(date: today, count: 0).level == 0)
        assert(Day(date: today, count: 1).level == 1)
        assert(Day(date: today, count: 3).level == 2)
        assert(Day(date: today, count: 6).level == 3)
        assert(Day(date: today, count: 99).level == 4)
    }
}
#endif
