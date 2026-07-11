import SwiftUI
import WidgetKit
import AppKit

struct ContributionGridView: View {
    let entry: ContributionEntry

    // GitHub palette, adaptive: light values for light mode, dark values for dark.
    // Index 0 is the empty cell; 1...4 are increasing intensity.
    private static let palette: [Color] = [
        adaptiveColor(0xEBEDF0, 0x2D333B),
        adaptiveColor(0x9BE9A8, 0x0E4429),
        adaptiveColor(0x40C463, 0x006D32),
        adaptiveColor(0x30A14E, 0x26A641),
        adaptiveColor(0x216E39, 0x39D353),
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
            let pad: CGFloat = 12       // buffer around the grid
            let spacing: CGFloat = 3    // gap between cells
            let monthH: CGFloat = 12
            let vGap: CGFloat = 4       // grid -> month labels

            let availW = geo.size.width - pad * 2
            let availH = geo.size.height - pad * 2 - monthH - vGap
            // Square cells: fit both axes, then center the whole block.
            let cell = max(2, min((availW - spacing * CGFloat(cols - 1)) / CGFloat(cols),
                                  (availH - spacing * 6) / 7))
            let step = cell + spacing
            let gridW = cell * CGFloat(cols) + spacing * CGFloat(cols - 1)
            let radius = max(2, cell * 0.2)

            VStack(spacing: vGap) {
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(weeks.indices, id: \.self) { c in
                        VStack(spacing: spacing) {
                            ForEach(weeks[c]) { day in
                                RoundedRectangle(cornerRadius: radius)
                                    .fill(Self.palette[day.level])
                                    .frame(width: cell, height: cell)
                            }
                        }
                    }
                }
                // Month labels, aligned under their columns.
                ZStack(alignment: .topLeading) {
                    ForEach(entry.grid.monthLabels) { label in
                        Text(label.name)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .offset(x: CGFloat(label.column) * step)
                    }
                }
                .frame(width: gridW, height: monthH, alignment: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.height) // centers the block
        }
    }

}

/// Appearance-adaptive color from two sRGB hex values (light, dark).
func adaptiveColor(_ light: UInt, _ dark: UInt) -> Color {
    func ns(_ h: UInt) -> NSColor {
        NSColor(srgbRed: CGFloat((h >> 16) & 0xFF) / 255,
                green: CGFloat((h >> 8) & 0xFF) / 255,
                blue: CGFloat(h & 0xFF) / 255, alpha: 1)
    }
    return Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? ns(dark) : ns(light)
    })
}
