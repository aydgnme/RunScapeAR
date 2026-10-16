//
//  RouteDetailViewModel.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import Observation

@MainActor
@Observable
final class RouteDetailViewModel {
    private let routeID: String
    private let getRoute: GetRouteUseCase

    private(set) var route: Route?
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
            route = try await getRoute.execute(
                id: routeID
            )
        } catch {
            errorMessage = String(
                describing: error
            )
        }
    }
}
