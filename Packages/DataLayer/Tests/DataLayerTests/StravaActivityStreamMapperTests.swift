//
//  StravaActivityStreamMapperTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Foundation
import Testing

@Test
// swiftlint:disable:next function_body_length
func activityStreamsAreMappedToActivityPoints() throws {
    let json = """
    {
        "latlng": {
            "data": [
                [47.6500, 26.2500],
                [47.6510, 26.2510]
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "distance": {
            "data": [0.0, 125.0],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "altitude": {
            "data": [312.0, 318.0],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "time": {
            "data": [0, 30],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "velocity_smooth": {
            "data": [3.1, 3.5],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "heartrate": {
            "data": [145, 151],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "cadence": {
            "data": [82, 84],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        "grade_smooth": {
            "data": [1.2, 4.8],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        }
    }
    """

    let streamSet = try JSONDecoder().decode(
        [String: StravaStreamDTO].self,
        from: Data(json.utf8)
    )

    let points = try StravaActivityStreamMapper().map(
        Array(streamSet.values)
    )

    #expect(points.count == 2)

    #expect(points[0].trackPoint.latitude == 47.6500)
    #expect(points[0].trackPoint.longitude == 26.2500)
    #expect(points[0].trackPoint.altitude == 312.0)
    #expect(points[0].trackPoint.distance == 0.0)

    #expect(points[0].time == 0)
    #expect(points[0].speed == 3.1)
    #expect(points[0].heartRate == 145)
    #expect(points[0].cadence == 82)
    #expect(points[0].grade == 1.2)

    #expect(points[1].trackPoint.altitude == 318.0)
    #expect(points[1].trackPoint.distance == 125.0)
    #expect(points[1].time == 30)
    #expect(points[1].speed == 3.5)
    #expect(points[1].heartRate == 151)
    #expect(points[1].cadence == 84)
    #expect(points[1].grade == 4.8)
}
