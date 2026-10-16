//
//  GetActivityUseCase.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct GetActivityUseCase: Sendable {
    private let repository: any ActivityRepository

    public init(repository: any ActivityRepository) {
        self.repository = repository
    }

    public func execute(id: String) async throws -> Activity {
        try await repository.fetchActivity(id: id)
    }
}
