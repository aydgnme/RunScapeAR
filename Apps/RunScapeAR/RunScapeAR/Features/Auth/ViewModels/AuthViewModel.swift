import AuthenticationServices
import DataLayer
import Observation

@MainActor
@Observable
final class AuthViewModel {
    private let config: StravaOAuthConfig
    private let oauthClient: StravaOAuthClient
    private let tokenStore: any TokenStore

    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        config: StravaOAuthConfig,
        oauthClient: StravaOAuthClient,
        tokenStore: any TokenStore
    ) {
        self.config = config
        self.oauthClient = oauthClient
        self.tokenStore = tokenStore

        isAuthenticated = (try? tokenStore.load()) != nil
    }

    func signIn() async {
        guard let authURL = config.authorizationURL else {
            errorMessage = "Invalid OAuth configuration."
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let callbackURL = try await authenticate(
                url: authURL,
                callbackScheme: "runscapear"
            )

            guard let code = extractCode(from: callbackURL) else {
                errorMessage = "Authentication was cancelled."
                return
            }

            let token = try await oauthClient.exchangeCode(code)
            try tokenStore.save(token)
            isAuthenticated = true
        } catch ASWebAuthenticationSessionError.canceledLogin {
            errorMessage = nil
        } catch {
            errorMessage = "Sign in failed. Please try again."
        }
    }

    func signOut() {
        try? tokenStore.delete()
        isAuthenticated = false
    }

    func handleExpiredSession() {
        try? tokenStore.delete()
        isAuthenticated = false
        errorMessage = "Your session has expired. Please sign in again."
    }

    private func authenticate(
        url: URL,
        callbackScheme: String
    ) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(
                        throwing: ASWebAuthenticationSessionError(
                            .canceledLogin
                        )
                    )
                }
            }

            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    private func extractCode(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "code" })?
            .value
    }
}
