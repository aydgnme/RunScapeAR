import Foundation

public final class StravaOAuthClient: Sendable {
    private let httpClient: any HTTPClient
    private let config: StravaOAuthConfig

    private let tokenURL = URL(
        string: "https://www.strava.com/oauth/token"
    )!

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
            "client_secret": config.clientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]

        return try await postTokenRequest(body)
    }

    public func refreshToken(
        _ refreshToken: String
    ) async throws -> StravaToken {
        let body = [
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]

        return try await postTokenRequest(body)
    }

    private func postTokenRequest(
        _ body: [String: String]
    ) async throws -> StravaToken {
        let jsonData = try JSONSerialization.data(
            withJSONObject: body
        )

        let request = HTTPRequest(
            url: tokenURL,
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
