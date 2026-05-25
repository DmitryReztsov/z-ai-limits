import SwiftUI

struct QuotaRowView: View {
    let item: QuotaItem

    var barColor: Color {
        if item.percentage > 0.8 { return .red }
        if item.percentage > 0.5 { return .orange }
        if item.percentage > 0.3 { return .yellow }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: item.iconName)
                    .font(.system(size: 12))
                    .foregroundStyle(barColor)
                    .frame(width: 18)
                Text(item.name)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text(item.usedLabel)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(nsColor: .separatorColor))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor.gradient)
                        .frame(
                            width: max(geometry.size.width * min(item.percentage, 1.0), item.percentage > 0 ? 4 : 0),
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.5), value: item.percentage)
                }
            }
            .frame(height: 6)

            HStack {
                if let reset = item.nextReset {
                    Text("Resets \(reset, style: .relative)")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                Text(item.remainingLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            if !item.subItems.isEmpty {
                Divider()
                    .padding(.vertical, 2)

                ForEach(item.subItems) { sub in
                    HStack(spacing: 6) {
                        Image(systemName: sub.iconName)
                            .font(.system(size: 10))
                            .foregroundStyle(.quaternary)
                            .frame(width: 14)
                        Text(sub.name)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(sub.usage))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(sub.usage > 0 ? .primary : .tertiary)
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 0.5)
        )
    }
}
