//
//  TrackPointProjectorTests.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
@testable import Platform
import Testing

@Test
func firstTrackPointBecomesOrigin() {
    let points = [
        TrackPoint(
            latitude: 47.6500,
            longitude: 26.2500,
            altitude: 312.0,
            distance: 0
        )
    ]

    let result = TrackPointProjector().project(
        points
    )

    #expect(result.count == 1)
    #expect(result[0].x == 0)
    #expect(result[0].y == 0)
    #expect(result[0].z == 0)
}

@Test
func trackPointsAreProjectedRelativeToOrigin() {
    let points = [
        TrackPoint(
            latitude: 47.6500,
            longitude: 26.2500,
            altitude: 312.0,
            distance: 0
        ),
        TrackPoint(
            latitude: 47.6510,
            longitude: 26.2510,
            altitude: 318.0,
            distance: 150
        )
    ]

    let result = TrackPointProjector().project(
        points
    )

    #expect(result.count == 2)

    #expect(result[1].x > 0)
    #expect(result[1].y == 6.0)
    #expect(result[1].z < 0)
}
