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

    var body: some View {
        if entry.username.isEmpty {
            Text("Set your LeetCode username in the widget's Edit panel")
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
            let spacing: CGFloat = 2
            let topH: CGFloat = 11
            let availW = geo.size.width
            let availH = geo.size.height - topH
            // Stretch cells to consume all available space (fills the widget).
            // ponytail: cells go non-square for long ranges; that's the price of
            // "fill the whole widget" with a fixed 7 rows and variable columns.
            let cellW = max(1, (availW - spacing * CGFloat(cols - 1)) / CGFloat(cols))
            let cellH = max(1, (availH - spacing * 6) / 7)
            let step = cellW + spacing

            VStack(alignment: .leading, spacing: 2) {
                // Month labels, positioned by column.
                ZStack(alignment: .topLeading) {
                    ForEach(entry.grid.monthLabels) { label in
                        Text(label.name)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .offset(x: CGFloat(label.column) * step)
                    }
                }
                .frame(height: topH, alignment: .topLeading)

                // Columns of days, edge to edge.
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(weeks.indices, id: \.self) { c in
                        VStack(spacing: spacing) {
                            ForEach(weeks[c]) { day in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Self.palette[day.level])
                                    .frame(width: cellW, height: cellH)
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
