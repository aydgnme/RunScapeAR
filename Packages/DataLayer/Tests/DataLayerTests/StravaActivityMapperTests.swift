//
//  StravaActivityMapperTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Testing

@Test
func activitySummaryMappedToDomainModel() {
    let dto = StravaActivitySummaryDTO(
        id: 12345,
        name: "Evening Run",
        distance: 4740.4,
        movingTime: 1200,
        elapsedTime: 1300,
        totalElevationGain: 83.4,
        sportType: "Run"
    )

    let summary = StravaActivityMapper().summary(from: dto)

    #expect(summary.id == "12345")
    #expect(summary.name == "Evening Run")
    #expect(summary.distance == 4740.4)
    #expect(summary.movingTime == 1200)
    #expect(summary.elapsedTime == 1300)
    #expect(summary.elevationGain == 83.4)
    #expect(summary.sportType == "Run")
}
