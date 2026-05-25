import Foundation
import SwiftUI

@Observable
@MainActor
final class QuotaViewModel {
    var quotaItems: [QuotaItem] = []
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?
    var overallUsage: Double = 0
    var planLevel: String = ""

    private var refreshTimer: Timer?
    private let refreshInterval: TimeInterval = 60

    var statusIconColor: NSColor {
        if errorMessage != nil { return .systemRed }
        if quotaItems.isEmpty { return .systemGray }
        if overallUsage > 0.8 { return .systemRed }
        if overallUsage > 0.5 { return .systemOrange }
        return .systemGreen
    }

    var statusIconName: String {
        if errorMessage != nil { return "exclamationmark.triangle.fill" }
        if quotaItems.isEmpty { return "circle.dashed" }
        if overallUsage > 0.8 { return "exclamationmark.circle.fill" }
        if overallUsage > 0.5 { return "exclamationmark.circle" }
        return "checkmark.circle.fill"
    }

    var hasApiKey: Bool {
        KeychainService.load() != nil
    }

    var timeSinceUpdate: String {
        guard let last = lastUpdated else { return "Never" }
        let interval = Date().timeIntervalSince(last)
        if interval < 5 { return "Just now" }
        if interval < 60 { return "\(Int(interval))s ago" }
        return "\(Int(interval / 60))m ago"
    }

    func saveApiKey(_ key: String) {
        do {
            if key.isEmpty {
                KeychainService.delete()
            } else {
                try KeychainService.save(token: key)
            }
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }
    }

    func loadApiKey() -> String {
        KeychainService.load() ?? ""
    }

    func refresh() {
        Task {
            await fetchQuota()
        }
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchQuota()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func fetchQuota() async {
        guard let token = KeychainService.load(), !token.isEmpty else {
            errorMessage = "No API key set. Click the gear icon to add your key."
            quotaItems = []
            overallUsage = 0
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.fetchQuota(token: token)
            quotaItems = response.items
            overallUsage = response.overallUsage
            lastUpdated = response.lastUpdated
            planLevel = response.level
        } catch let error as APIService.APIError {
            errorMessage = error.errorDescription
            if case .unauthorized = error {
                quotaItems = []
                overallUsage = 0
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
