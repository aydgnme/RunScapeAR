//
//  ActivityPointTests.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import Domain
import Testing

@Test
func activityPointStoresTelemetry() {
    let trackPoint = TrackPoint(
        latitude: 47.44,
        longitude: 25.56,
        altitude: 792,
        distance: 1250
    )

    let point = ActivityPoint(
        trackPoint: trackPoint,
        time: 420,
        speed: 2.8,
        heartRate: 152,
        cadence: 84,
        grade: 6.4
    )

    #expect(point.trackPoint.distance == 1250)
    #expect(point.time == 420)
    #expect(point.speed == 2.8)
    #expect(point.heartRate == 152)
    #expect(point.cadence == 84)
    #expect(point.grade == 6.4)
}
