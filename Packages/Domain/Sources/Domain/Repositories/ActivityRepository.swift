//
//  ActivityRepository.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public protocol ActivityRepository: Sendable {
    func fetchActivities() async throws -> [ActivitySummary]

    func fetchActivity(
        id: String
    ) async throws -> Activity
}
