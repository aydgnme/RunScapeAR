//
//  GetActivitiesUseCase.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct GetActivitiesUseCase: Sendable {
    private let repository: any ActivityRepository

    public init(repository: any ActivityRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [ActivitySummary] {
        try await repository.fetchActivities()
    }
}
