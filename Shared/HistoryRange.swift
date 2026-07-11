import AppIntents

/// How far back the contribution grid reaches. Presented as a menu in the
/// widget's Edit panel. All ranges are slices of LeetCode's trailing-year data.
enum HistoryRange: String, CaseIterable, Identifiable, AppEnum {
    case month, threeMonths, sixMonths, year

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .month: return 31
        case .threeMonths: return 92
        case .sixMonths: return 183
        case .year: return 365
        }
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "History" }

    static var caseDisplayRepresentations: [HistoryRange: DisplayRepresentation] {
        [
            .month: "Last month",
            .threeMonths: "Last 3 months",
            .sixMonths: "Last 6 months",
            .year: "Last year",
        ]
    }
}
