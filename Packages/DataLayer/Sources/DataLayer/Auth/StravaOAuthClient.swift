import Foundation

public final class StravaOAuthClient: Sendable {
    private let httpClient: any HTTPClient
    private let config: StravaOAuthConfig

    public init(
        httpClient: any HTTPClient,
        config: StravaOAuthConfig
    ) {
        self.httpClient = httpClient
        self.config = config
    }

    public func exchangeCode(
        _ code: String
    ) async throws -> StravaToken {
        let body = [
            "client_id": config.clientID,
            "code": code
        ]

        let url = config.brokerURL.appendingPathComponent("token")
        return try await postTokenRequest(body, to: url)
    }

    public func refreshToken(
        _ refreshToken: String
    ) async throws -> StravaToken {
        let body = [
            "client_id": config.clientID,
            "refresh_token": refreshToken
        ]

        let url = config.brokerURL.appendingPathComponent("refresh")
        return try await postTokenRequest(body, to: url)
    }

    private func postTokenRequest(
        _ body: [String: String],
        to url: URL
    ) async throws -> StravaToken {
        let jsonData = try JSONSerialization.data(
            withJSONObject: body
        )

        let request = HTTPRequest(
            url: url,
            method: .post,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            body: jsonData
        )

        let response = try await httpClient.send(request)

        guard (200 ..< 300).contains(response.statusCode) else {
            throw StravaOAuthError.tokenExchangeFailed(
                response.statusCode
            )
        }

        let dto = try JSONDecoder().decode(
            StravaTokenResponseDTO.self,
            from: response.data
        )

        return StravaToken(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresAt: Date(
                timeIntervalSince1970: TimeInterval(dto.expiresAt)
            ),
            athleteID: dto.athlete?.id ?? 0
        )
    }
}

public enum StravaOAuthError: Error, Sendable {
    case tokenExchangeFailed(Int)
    case noToken
}

private struct StravaTokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int64
    let athlete: AthleteDTO?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case athlete
    }

    struct AthleteDTO: Decodable {
        let id: Int64
    }
}
