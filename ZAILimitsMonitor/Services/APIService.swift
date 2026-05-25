import Foundation

actor APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "https://api.z.ai")!

    func fetchQuota(token: String) async throws -> QuotaResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("/api/monitor/usage/quota/limit"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        if httpResponse.statusCode == 429 {
            throw APIError.rateLimited
        }

        guard httpResponse.statusCode == 200 else {
            if let body = String(data: data, encoding: .utf8) {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: body)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Unknown error")
        }

        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)

        guard apiResponse.success else {
            throw APIError.apiError(code: apiResponse.code, message: apiResponse.msg)
        }

        let items = QuotaItem.from(apiResponse.data.limits)

        return QuotaResponse(
            items: items,
            level: apiResponse.data.level,
            lastUpdated: Date()
        )
    }

    enum APIError: LocalizedError {
        case unauthorized
        case rateLimited
        case invalidResponse
        case apiError(code: Int, message: String)
        case serverError(statusCode: Int, message: String)
        case networkError(Error)

        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return "Invalid or expired API key. Please update it in Settings."
            case .rateLimited:
                return "Rate limited. Please wait before trying again."
            case .invalidResponse:
                return "Invalid response from server."
            case .apiError(let code, let msg):
                return "API error (\(code)): \(msg)"
            case .serverError(let code, let msg):
                return "Server error (\(code)): \(msg)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
}
