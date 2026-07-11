import SwiftUI
import WidgetKit

struct ContributionGridView: View {
    let entry: ContributionEntry

    // GitHub green palette (level 0...4).
    private static let palette: [Color] = [
        Color(hex: 0xEBEDF0),
        Color(hex: 0x9BE9A8),
        Color(hex: 0x40C463),
        Color(hex: 0x30A14E),
        Color(hex: 0x216E39),
    ]
    // Row order is Sun...Sat; GitHub labels only Mon/Wed/Fri.
    private let weekdayLabels = ["", "Mon", "", "Wed", "", "Fri", ""]

    var body: some View {
        if entry.username.isEmpty {
            Text("Set your LeetCode username in the app")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            grid
        }
    }

    private var grid: some View {
        GeometryReader { geo in
            let weeks = entry.grid.weeks
            let cols = max(weeks.count, 1)
            let labelW: CGFloat = 20
            let topH: CGFloat = 11
            let spacing: CGFloat = 2
            let availW = geo.size.width - labelW
            let availH = geo.size.height - topH
            let cell = max(2, min((availW - spacing * CGFloat(cols - 1)) / CGFloat(cols),
                                  (availH - spacing * 6) / 7))
            let step = cell + spacing

            VStack(alignment: .leading, spacing: 2) {
                // Month labels, positioned by column.
                ZStack(alignment: .topLeading) {
                    ForEach(entry.grid.monthLabels) { label in
                        Text(label.name)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .offset(x: labelW + CGFloat(label.column) * step)
                    }
                }
                .frame(height: topH, alignment: .topLeading)

                HStack(alignment: .top, spacing: spacing) {
                    // Weekday labels.
                    VStack(spacing: spacing) {
                        ForEach(0..<7, id: \.self) { row in
                            Text(weekdayLabels[row])
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                                .frame(width: labelW - 2, height: cell, alignment: .trailing)
                        }
                    }
                    // Columns of days.
                    ForEach(weeks.indices, id: \.self) { c in
                        VStack(spacing: spacing) {
                            ForEach(weeks[c]) { day in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Self.palette[day.level])
                                    .frame(width: cell, height: cell)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
