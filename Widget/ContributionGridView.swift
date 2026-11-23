import SwiftUI
import WidgetKit
import AppKit

struct ContributionGridView: View {
    let entry: ContributionEntry

    // GitHub palette, adaptive: light values for light mode, dark for dark.
    // Index 0 is the empty cell; 1...4 are increasing intensity.
    private static let palette: [Color] = [
        adaptiveColor(0xEBEDF0, 0x2D333B),
        adaptiveColor(0x9BE9A8, 0x0E4429),
        adaptiveColor(0x40C463, 0x006D32),
        adaptiveColor(0x30A14E, 0x26A641),
        adaptiveColor(0x216E39, 0x39D353),
    ]

    var body: some View {
        ZStack {
            // Opaque base so the wallpaper never shows through, whatever the
            // system does with the container background.
            adaptiveColor(0xFFFFFF, 0x1C1C1E)
            content
                .widgetAccentable()
        }
    }

    @ViewBuilder private var content: some View {
        if entry.username.isEmpty {
            Text("Set your LeetCode username in the widget's Edit panel")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            grid
        }
    }

    private var grid: some View {
        GeometryReader { geo in
            let sidePad: CGFloat = 8
            let topPad: CGFloat = 12    // 1.5x the bottom margin
            let botPad: CGFloat = 8
            let spacing: CGFloat = 3
            let monthH: CGFloat = 12
            let vGap: CGFloat = 4

            let availW = geo.size.width - sidePad * 2
            let availH = geo.size.height - topPad - botPad - monthH - vGap
            // Square cells sized to fill the full height (top to bottom).
            let cell = max(2, (availH - spacing * 6) / 7)
            let step = cell + spacing
            // Show the most recent weeks that fit the width as full squares.
            let maxCols = max(1, Int((availW + spacing) / step))
            let weeks = entry.grid.weeks.count > maxCols
                ? Array(entry.grid.weeks.suffix(maxCols))
                : entry.grid.weeks
            let cols = weeks.count
            let gridW = cell * CGFloat(cols) + spacing * CGFloat(cols - 1)
            let radius = max(2, cell * 0.2)
            let labels = monthLabels(weeks, step: step)

            VStack(spacing: 0) {
                Color.clear.frame(height: topPad)
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
                    // Month labels aligned under the first column of each month.
                    ZStack(alignment: .topLeading) {
                        ForEach(labels) { label in
                            Text(label.name)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .offset(x: CGFloat(label.column) * step)
                        }
                    }
                    .frame(width: gridW, height: monthH, alignment: .topLeading)
                }
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    /// Label the first visible column of each month, dropping any that would
    /// collide with the month after it (the leading partial month usually).
    private func monthLabels(_ weeks: [[Day]], step: CGFloat) -> [MonthLabel] {
        let cal = Calendar.current
        let df = DateFormatter()
        df.dateFormat = "MMM"
        var out: [MonthLabel] = []
        var lastMonth = -1
        for (c, week) in weeks.enumerated() {
            guard let first = week.first?.date else { continue }
            let month = cal.component(.month, from: first)
            if month != lastMonth {
                out.append(MonthLabel(column: c, name: df.string(from: first)))
                lastMonth = month
            }
        }
        // ponytail: "MMM" at 9pt is ~22pt wide; walk newest-first so a squeezed
        // pair keeps the more recent month.
        let minGap = 22 / step
        var kept: [MonthLabel] = []
        for label in out.reversed() {
            if let prev = kept.last, CGFloat(prev.column - label.column) < minGap { continue }
            kept.append(label)
        }
        return kept.reversed()
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
