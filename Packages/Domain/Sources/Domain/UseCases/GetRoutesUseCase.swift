//
//  GetRoutesUseCase.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct GetRoutesUseCase: Sendable {
    private let repository: any RouteRepository

    public init(repository: any RouteRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [RouteSummary] {
        try await repository.fetchRoutes()
    }
}
