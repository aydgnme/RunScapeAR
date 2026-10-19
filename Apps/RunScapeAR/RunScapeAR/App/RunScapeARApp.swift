import DataLayer
import Domain
import SwiftUI

@main
struct RunScapeARApp: App {
    @State private var authViewModel: AuthViewModel

    private let tokenStore: any TokenStore
    private let oauthClient: StravaOAuthClient
    private let oauthConfig: StravaOAuthConfig
    private let httpClient: any HTTPClient
    private let stravaClient: StravaClient

    init() {
        let httpClient = URLSessionHTTPClient()
        self.httpClient = httpClient

        let brokerURLString = ProcessInfo.processInfo.environment[
            "OAUTH_BROKER_URL"
        ] ?? "http://localhost:3000"

        let config = StravaOAuthConfig(
            clientID: ProcessInfo.processInfo.environment[
                "STRAVA_CLIENT_ID"
            ] ?? "",
            brokerURL: URL(string: brokerURLString)!
        )

        oauthConfig = config

        let tokenStore = KeychainTokenStore()
        self.tokenStore = tokenStore

        let oauthClient = StravaOAuthClient(
            httpClient: httpClient,
            config: config
        )

        self.oauthClient = oauthClient

        let tokenProvider: any AccessTokenProvider = if let envToken = ProcessInfo.processInfo.environment[
            "STRAVA_ACCESS_TOKEN"
        ], !envToken.isEmpty {
            EnvironmentAccessTokenProvider()
        } else {
            OAuthAccessTokenProvider(
                tokenStore: tokenStore,
                oauthClient: oauthClient
            )
        }

        stravaClient = StravaClient(
            httpClient: httpClient,
            tokenProvider: tokenProvider
        )

        let authVM = AuthViewModel(
            config: config,
            oauthClient: oauthClient,
            tokenStore: tokenStore
        )

        _authViewModel = State(initialValue: authVM)
    }

    var body: some Scene {
        WindowGroup {
            if usesEnvironmentToken || authViewModel.isAuthenticated {
                RoutesView(
                    viewModel: makeRoutesViewModel(),
                    makeRouteDetailViewModel:
                    makeRouteDetailViewModel,
                    showSignOut: !usesEnvironmentToken,
                    onSignOut: { authViewModel.signOut() }
                )
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }

    private var usesEnvironmentToken: Bool {
        if let token = ProcessInfo.processInfo.environment[
            "STRAVA_ACCESS_TOKEN"
        ] {
            return !token.isEmpty
        }
        return false
    }

    @MainActor
    private func makeRoutesViewModel() -> RoutesViewModel {
        let repository = StravaRouteRepository(
            client: stravaClient
        )

        return RoutesViewModel(
            getRoutes: GetRoutesUseCase(
                repository: repository
            )
        )
    }

    @MainActor
    private func makeRouteDetailViewModel(
        routeID: String
    ) -> RouteDetailViewModel {
        let repository = StravaRouteRepository(
            client: stravaClient
        )

        return RouteDetailViewModel(
            routeID: routeID,
            getRoute: GetRouteUseCase(
                repository: repository
            )
        )
    }
}
