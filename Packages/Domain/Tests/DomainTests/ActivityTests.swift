//
//  ActivityTests.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import Domain
import Testing

@Test
func activityStoresActivityInformation() {
    let points = [
        ActivityPoint(
            trackPoint: TrackPoint(
                latitude: 47.44,
                longitude: 25.56,
                altitude: 792,
                distance: 0
            ),
            time: 0,
            speed: 2.4,
            heartRate: 148,
            cadence: 82,
            grade: 4.2
        )
    ]

    let activity = Activity(
        id: "activity-1",
        name: "Morning Hike",
        distance: 12400,
        movingTime: 8400,
        elapsedTime: 9200,
        elevationGain: 684,
        averageSpeed: 1.47,
        maximumSpeed: 3.21,
        averageHeartRate: 148,
        maximumHeartRate: 171,
        points: points
    )

    #expect(activity.id == "activity-1")
    #expect(activity.name == "Morning Hike")
    #expect(activity.distance == 12400)
    #expect(activity.elevationGain == 684)
    #expect(activity.averageHeartRate == 148)
    #expect(activity.points.count == 1)
    #expect(activity.points[0].heartRate == 148)
    #expect(activity.points[0].grade == 4.2)
}
