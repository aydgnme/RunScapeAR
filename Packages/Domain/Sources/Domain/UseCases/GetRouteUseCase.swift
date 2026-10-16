//
//  GetRouteUseCase.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct GetRouteUseCase: Sendable {
    private let repository: any RouteRepository

    public init(repository: any RouteRepository) {
        self.repository = repository
    }

    public func execute(id: String) async throws -> Route {
        try await repository.fetchRoute(id: id)
    }
}
