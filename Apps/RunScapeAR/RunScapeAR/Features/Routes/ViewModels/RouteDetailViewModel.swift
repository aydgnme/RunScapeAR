import Domain
import Observation

@MainActor
@Observable
final class RouteDetailViewModel {
    private let routeID: String
    private let getRoute: GetRouteUseCase
    private let elevationAnalyzer = ElevationAnalyzer()

    private(set) var route: Route?
    private(set) var statistics: RouteStatistics?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        routeID: String,
        getRoute: GetRouteUseCase
    ) {
        self.routeID = routeID
        self.getRoute = getRoute
    }

    func load() async {
        guard
            route == nil,
            !isLoading
        else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let loaded = try await getRoute.execute(
                id: routeID
            )

            route = loaded
            statistics = elevationAnalyzer.analyze(
                points: loaded.points
            )
        } catch {
            errorMessage = userMessage(for: error)
        }
    }

    func retry() async {
        route = nil
        statistics = nil
        errorMessage = nil
        await load()
    }

    private func userMessage(
        for error: Error
    ) -> String {
        StravaDisplayError(error).userMessage
    }
}
