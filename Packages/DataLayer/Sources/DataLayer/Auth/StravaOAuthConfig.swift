import Foundation

public struct StravaOAuthConfig: Sendable {
    public let clientID: String
    public let clientSecret: String
    public let redirectURI: String
    public let scopes: String

    public init(
        clientID: String,
        clientSecret: String,
        redirectURI: String = "runscapear://oauth/callback",
        scopes: String = "read,read_all,activity:read_all"
    ) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.scopes = scopes
    }

    public var authorizationURL: URL? {
        var components = URLComponents(
            string: "https://www.strava.com/oauth/mobile/authorize"
        )

        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: scopes)
        ]

        return components?.url
    }
}
