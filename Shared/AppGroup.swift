import Foundation

/// Shared config store between the app and the widget extension.
///
/// ponytail: if App Group entitlements won't provision on your free Apple ID,
/// hardcode `username` below (return a literal), drop the app-group entitlement
/// from both .entitlements files, and swap `defaults` for `.standard`.
enum AppGroup {
    static let identifier = "group.com.leetgit"
    static let defaults = UserDefaults(suiteName: identifier) ?? .standard

    enum Key {
        static let username = "username"
        static let range = "range"
    }

    static var username: String {
        defaults.string(forKey: Key.username) ?? ""
    }

    static var range: HistoryRange {
        HistoryRange(rawValue: defaults.string(forKey: Key.range) ?? "") ?? .year
    }
}

enum HistoryRange: String, CaseIterable, Identifiable {
    case month, threeMonths, sixMonths, year

    var id: String { rawValue }

    var label: String {
        switch self {
        case .month: return "Last month"
        case .threeMonths: return "Last 3 months"
        case .sixMonths: return "Last 6 months"
        case .year: return "Last year"
        }
    }

    var days: Int {
        switch self {
        case .month: return 31
        case .threeMonths: return 92
        case .sixMonths: return 183
        case .year: return 365
        }
    }
}
