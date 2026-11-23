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

        // LeetCode keys each bucket by that day's UTC midnight, so the key is a
        // date *label*, not an instant to convert. Read the calendar date back
        // out in UTC and re-file it under the same-numbered local day. Calling
        // startOfDay on the raw timestamp instead lands every bucket a day early
        // anywhere west of Greenwich — in Los Angeles, UTC midnight is 5pm the
        // previous afternoon, so today's submissions showed up on yesterday.
        let local = Calendar.current
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? utc.timeZone

        var result: [Date: Int] = [:]
        for (tsString, count) in raw {
            guard let ts = TimeInterval(tsString) else { continue }
            let parts = utc.dateComponents([.year, .month, .day], from: Date(timeIntervalSince1970: ts))
            guard let day = local.date(from: parts) else { continue }
            result[day] = count
        }
        return result
    }
}
