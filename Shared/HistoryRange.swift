import AppIntents

/// How far back the contribution grid reaches. Presented as a menu in the
/// widget's Edit panel. All ranges are slices of LeetCode's trailing-year data.
public enum HistoryRange: String, CaseIterable, Identifiable, AppEnum {
    // Raw values are what AppIntents persists for a configured widget — renaming
    // a case resets the user's selection to the default, so `month` stays
    // `month` even though it now means four weeks.
    case month, threeMonths, sixMonths, year

    public var id: String { rawValue }

    /// Number of Sunday-start columns, including the current partial week.
    public var weeks: Int {
        switch self {
        case .month: return 4
        case .threeMonths: return 13
        case .sixMonths: return 26
        case .year: return 52
        }
    }

    public static var typeDisplayRepresentation: TypeDisplayRepresentation { "History" }

    public static var caseDisplayRepresentations: [HistoryRange: DisplayRepresentation] {
        [
            .month: "Last 4 weeks",
            .threeMonths: "Last 3 months",
            .sixMonths: "Last 6 months",
            .year: "Last year",
        ]
    }
}
