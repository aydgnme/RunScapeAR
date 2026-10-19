import DataLayer
import Domain
import Foundation

enum PreviewData {
    static let trackPoints: [TrackPoint] = [
        TrackPoint(latitude: 41.015, longitude: 28.979, altitude: 50, distance: 0),
        TrackPoint(latitude: 41.016, longitude: 28.980, altitude: 55, distance: 130),
        TrackPoint(latitude: 41.017, longitude: 28.982, altitude: 70, distance: 320),
        TrackPoint(latitude: 41.018, longitude: 28.983, altitude: 85, distance: 480),
        TrackPoint(latitude: 41.019, longitude: 28.985, altitude: 65, distance: 700),
        TrackPoint(latitude: 41.020, longitude: 28.986, altitude: 50, distance: 900),
        TrackPoint(latitude: 41.021, longitude: 28.988, altitude: 60, distance: 1150),
        TrackPoint(latitude: 41.022, longitude: 28.990, altitude: 80, distance: 1400),
        TrackPoint(latitude: 41.023, longitude: 28.991, altitude: 95, distance: 1600),
        TrackPoint(latitude: 41.024, longitude: 28.993, altitude: 75, distance: 1850),
        TrackPoint(latitude: 41.025, longitude: 28.994, altitude: 55, distance: 2100)
    ]

    static let route = Route(
        id: "1",
        name: "Bosphorus Morning Run",
        distance: 2100,
        elevationGain: 120,
        points: trackPoints
    )

    static let routeSummaries: [RouteSummary] = [
        RouteSummary(
            id: "1",
            name: "Bosphorus Morning Run",
            distance: 13200,
            elevationGain: 245
        ),
        RouteSummary(
            id: "2",
            name: "Belgrad Forest Loop",
            distance: 8500,
            elevationGain: 180
        ),
        RouteSummary(
            id: "3",
            name: "Kadiköy Coastal Path",
            distance: 5400,
            elevationGain: 35
        )
    ]
}

private struct PreviewRouteRepository: RouteRepository {
    func fetchRoutes() async throws -> [RouteSummary] {
        PreviewData.routeSummaries
    }

    func fetchRoute(id _: String) async throws -> Route {
        PreviewData.route
    }
}

@MainActor
enum PreviewFactory {
    static func routesViewModel() -> RoutesViewModel {
        RoutesViewModel(
            getRoutes: GetRoutesUseCase(
                repository: PreviewRouteRepository()
            )
        )
    }

    static func routeDetailViewModel() -> RouteDetailViewModel {
        RouteDetailViewModel(
            routeID: "1",
            getRoute: GetRouteUseCase(
                repository: PreviewRouteRepository()
            )
        )
    }

    static func authViewModel() -> AuthViewModel {
        let httpClient = URLSessionHTTPClient()
        let config = StravaOAuthConfig(
            clientID: "preview",
            brokerURL: URL(string: "http://localhost:3000")!
        )
        let oauthClient = StravaOAuthClient(
            httpClient: httpClient,
            config: config
        )

        return AuthViewModel(
            config: config,
            oauthClient: oauthClient,
            tokenStore: PreviewTokenStore()
        )
    }
}

private struct PreviewTokenStore: TokenStore {
    func save(_: StravaToken) throws {}
    func load() throws -> StravaToken? {
        nil
    }

    func delete() throws {}
}
