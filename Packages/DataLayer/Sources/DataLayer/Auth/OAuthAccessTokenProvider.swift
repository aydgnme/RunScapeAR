import Foundation

public actor OAuthAccessTokenProvider: AccessTokenProvider {
    private let tokenStore: any TokenStore
    private let oauthClient: StravaOAuthClient

    public init(
        tokenStore: any TokenStore,
        oauthClient: StravaOAuthClient
    ) {
        self.tokenStore = tokenStore
        self.oauthClient = oauthClient
    }

    public func accessToken() async throws -> String {
        guard var token = try tokenStore.load() else {
            throw StravaOAuthError.noToken
        }

        if token.isExpired {
            token = try await oauthClient.refreshToken(
                token.refreshToken
            )

            try tokenStore.save(token)
        }

        return token.accessToken
    }
}
