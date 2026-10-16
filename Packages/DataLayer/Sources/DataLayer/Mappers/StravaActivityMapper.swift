//
//  StravaActivityMapper.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Domain
import Foundation

struct StravaActivityMapper: Sendable {
    func summary(
        from dto: StravaActivitySummaryDTO
    ) -> ActivitySummary {
        ActivitySummary(
            id: String(dto.id),
            name: dto.name,
            distance: dto.distance,
            movingTime: TimeInterval(dto.movingTime),
            elapsedTime: TimeInterval(dto.elapsedTime),
            elevationGain: dto.totalElevationGain,
            sportType: dto.sportType
        )
    }

    func activity(
        from dto: StravaActivityDTO,
        points: [ActivityPoint]
    ) -> Activity {
        Activity(
            id: String(dto.id),
            name: dto.name,
            distance: dto.distance,
            movingTime: TimeInterval(dto.movingTime),
            elapsedTime: TimeInterval(dto.elapsedTime),
            elevationGain: dto.totalElevationGain,
            averageSpeed: dto.averageSpeed,
            maximumSpeed: dto.maxSpeed,
            averageHeartRate: dto.averageHeartRate,
            maximumHeartRate: dto.maxHeartRate,
            points: points
        )
    }
}
