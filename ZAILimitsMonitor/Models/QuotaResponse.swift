import Foundation

struct APIResponse: Codable {
    let code: Int
    let msg: String
    let data: APIResponseData
    let success: Bool
}

struct APIResponseData: Codable {
    let limits: [APILimit]
    let level: String
}

struct APILimit: Codable {
    let type: String
    let unit: Int?
    let number: Int?
    let usage: Double?
    let currentValue: Double?
    let remaining: Double?
    let percentage: Double?
    let nextResetTime: Double?
    let usageDetails: [APIUsageDetail]?

    enum CodingKeys: String, CodingKey {
        case type, unit, number, usage, currentValue, remaining, percentage, nextResetTime, usageDetails
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        type = try c.decode(String.self, forKey: .type)
        unit = try c.decodeIfPresent(Int.self, forKey: .unit)
        number = try c.decodeIfPresent(Int.self, forKey: .number)
        usage = try c.decodeIfPresent(Double.self, forKey: .usage)
        currentValue = try c.decodeIfPresent(Double.self, forKey: .currentValue)
        remaining = try c.decodeIfPresent(Double.self, forKey: .remaining)
        percentage = try c.decodeIfPresent(Double.self, forKey: .percentage)
        nextResetTime = try c.decodeIfPresent(Double.self, forKey: .nextResetTime)
        usageDetails = try c.decodeIfPresent([APIUsageDetail].self, forKey: .usageDetails)
    }
}

struct APIUsageDetail: Codable {
    let modelCode: String
    let usage: Double
}

struct SubQuota: Identifiable {
    let id = UUID()
    let name: String
    let usage: Double
    let iconName: String

    static func name(for code: String) -> String {
        switch code {
        case "search-prime": return "Web Search"
        case "web-reader": return "Web Reader"
        case "zread": return "Zread"
        default: return code
        }
    }

    static func icon(for code: String) -> String {
        switch code {
        case "search-prime": return "magnifyingglass"
        case "web-reader": return "doc.text.magnifyingglass"
        case "zread": return "book"
        default: return "circle"
        }
    }
}

struct QuotaItem: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let usedLabel: String
    let remainingLabel: String
    let nextReset: Date?
    let subItems: [SubQuota]
    let iconName: String
    let limitType: String
    let sortOrder: Int

    static func from(_ limits: [APILimit]) -> [QuotaItem] {
        let items = limits.compactMap { limit -> QuotaItem? in
            let pct = (limit.percentage ?? 0) / 100.0

            let name: String
            let icon: String
            let usedLabel: String
            let remainingLabel: String
            let sortOrder: Int

            switch limit.type {
            case "TIME_LIMIT":
                guard let u = limit.unit else { return nil }
                name = "Other tools"
                icon = "wrench.and.screwdriver"
                let used = limit.currentValue ?? 0
                let total = limit.usage ?? 0
                let rem = limit.remaining ?? 0
                usedLabel = "\(Int(pct * 100))% used"
                remainingLabel = "\(Int((1 - pct) * 100))% left"
                sortOrder = 1

            case "TOKENS_LIMIT":
                guard let u = limit.unit else { return nil }
                switch u {
                case 3:
                    name = "5 hours"
                    icon = "clock"
                case 6:
                    name = "Weekly"
                    icon = "calendar"
                default:
                    name = "Period"
                    icon = "calendar"
                }
                usedLabel = "\(Int(pct * 100))% used"
                remainingLabel = "\(Int((1 - pct) * 100))% left"
                sortOrder = 0

            default:
                name = limit.type
                icon = "chart.bar"
                usedLabel = "\(Int(pct * 100))%"
                remainingLabel = ""
                sortOrder = 0
            }

            let subItems: [SubQuota] = (limit.usageDetails ?? []).map { detail in
                SubQuota(
                    name: SubQuota.name(for: detail.modelCode),
                    usage: detail.usage,
                    iconName: SubQuota.icon(for: detail.modelCode)
                )
            }

            let resetDate = limit.nextResetTime.map {
                Date(timeIntervalSince1970: $0 / 1000.0)
            }

            return QuotaItem(
                name: name,
                percentage: pct,
                usedLabel: usedLabel,
                remainingLabel: remainingLabel,
                nextReset: resetDate,
                subItems: subItems,
                iconName: icon,
                limitType: limit.type,
                sortOrder: sortOrder
            )
        }
        return items.sorted { $0.sortOrder < $1.sortOrder }
    }
}

struct QuotaResponse {
    let items: [QuotaItem]
    let level: String
    let lastUpdated: Date

    var overallUsage: Double {
        guard !items.isEmpty else { return 0 }
        return items.map(\.percentage).reduce(0, +) / Double(items.count)
    }
}
