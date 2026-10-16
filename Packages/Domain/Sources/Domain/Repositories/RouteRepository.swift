//
//  RouteRepository.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public protocol RouteRepository: Sendable {
    func fetchRoutes() async throws -> [RouteSummary]

    func fetchRoute(
        id: String
    ) async throws -> Route
}
