//
//  RunScapeARApp.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 02/10/2026.
//

import DataLayer
import Domain
import SwiftUI

@main
struct RunScapeARApp: App {
    private let routeRepository: StravaRouteRepository

    init() {
        let tokenProvider =
            EnvironmentAccessTokenProvider()

        let httpClient =
            URLSessionHTTPClient()

        let stravaClient = StravaClient(
            httpClient: httpClient,
            tokenProvider: tokenProvider
        )

        routeRepository = StravaRouteRepository(
            client: stravaClient
        )
    }

    var body: some Scene {
        WindowGroup {
            RoutesView(
                viewModel: makeRoutesViewModel(),
                makeRouteDetailViewModel:
                makeRouteDetailViewModel
            )
        }
    }

    @MainActor
    private func makeRoutesViewModel() -> RoutesViewModel {
        RoutesViewModel(
            getRoutes: GetRoutesUseCase(
                repository: routeRepository
            )
        )
    }

    @MainActor
    private func makeRouteDetailViewModel(
        routeID: String
    ) -> RouteDetailViewModel {
        RouteDetailViewModel(
            routeID: routeID,
            getRoute: GetRouteUseCase(
                repository: routeRepository
            )
        )
    }
}
