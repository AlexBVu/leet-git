import Foundation

/// Fetches a user's LeetCode submission calendar (trailing ~year) with no auth.
enum LeetCodeAPI {
    private struct Response: Decodable {
        struct DataField: Decodable {
            struct MatchedUser: Decodable { let submissionCalendar: String? }
            let matchedUser: MatchedUser?
        }
        let data: DataField?
    }

    /// Returns a map of local-day-start -> submission count. Empty on any failure.
    static func fetchCalendar(username: String) async -> [Date: Int] {
        guard !username.isEmpty,
              let url = URL(string: "https://leetcode.com/graphql") else { return [:] }

        let body: [String: Any] = [
            "query": "query($u:String!){matchedUser(username:$u){submissionCalendar}}",
            "variables": ["u": username],
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let decoded = try? JSONDecoder().decode(Response.self, from: data),
              let json = decoded.data?.matchedUser?.submissionCalendar,
              let calData = json.data(using: .utf8),
              let raw = (try? JSONSerialization.jsonObject(with: calData)) as? [String: Int]
        else { return [:] }

        // ponytail: LeetCode keys days by UTC midnight; we bucket into the local
        // calendar day. Fine for a personal tracker; edge days may shift by one.
        let cal = Calendar.current
        var result: [Date: Int] = [:]
        for (tsString, count) in raw {
            guard let ts = TimeInterval(tsString) else { continue }
            let day = cal.startOfDay(for: Date(timeIntervalSince1970: ts))
            result[day] = count
        }
        return result
    }
}
