//
//  StravaActivityRepositoryTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Foundation
import Testing

private actor MockActivityStravaAPI: StravaAPI {
    private var activitiesResult: [StravaActivitySummaryDTO] = []
    private var activityResult: StravaActivityDTO?
    private var activityStreamsResult: [StravaStreamDTO] = []

    func activities(
        page: Int,
        perPage: Int
    ) async throws -> [StravaActivitySummaryDTO] {
        activitiesResult
    }

    func activity(
        id: Int64
    ) async throws -> StravaActivityDTO {
        guard let activityResult else {
            fatalError("activityResult not configured")
        }

        return activityResult
    }

    func activityStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO] {
        activityStreamsResult
    }

    func setActivities(
        _ activities: [StravaActivitySummaryDTO]
    ) {
        activitiesResult = activities
    }

    func setActivity(
        _ activity: StravaActivityDTO
    ) {
        activityResult = activity
    }

    func setActivityStreams(
        _ streams: [StravaStreamDTO]
    ) {
        activityStreamsResult = streams
    }

    // MARK: - Unused Route API

    func authenticatedAthlete() async throws -> StravaAthleteDTO {
        fatalError("Unexpected API call")
    }

    func routes(
        athleteID: Int64,
        page: Int,
        perPage: Int
    ) async throws -> [StravaRouteDTO] {
        fatalError("Unexpected API call")
    }

    func route(
        id: Int64
    ) async throws -> StravaRouteDTO {
        fatalError("Unexpected API call")
    }

    func routeStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO] {
        fatalError("Unexpected API call")
    }
}

@Test
func fetchActivitiesMapsStravaActivitiesToDomainSummaries() async throws {
    let api = MockActivityStravaAPI()

    await api.setActivities([
        StravaActivitySummaryDTO(
            id: 2001,
            name: "Evening Run",
            distance: 4083.4,
            movingTime: 1800,
            elapsedTime: 1950,
            totalElevationGain: 44.0,
            sportType: "Run"
        )
    ])

    let repository = StravaActivityRepository(
        api: api
    )

    let activities = try await repository.fetchActivities()

    #expect(activities.count == 1)

    #expect(activities[0].id == "2001")
    #expect(activities[0].name == "Evening Run")
    #expect(activities[0].distance == 4083.4)
    #expect(activities[0].movingTime == 1800)
    #expect(activities[0].elapsedTime == 1950)
    #expect(activities[0].elevationGain == 44.0)
    #expect(activities[0].sportType == "Run")
}

@Test
// swiftlint:disable:next function_body_length
func fetchActivityMapsDetailAndStreamsToDomainActivity() async throws {
    let api = MockActivityStravaAPI()

    await api.setActivity(
        StravaActivityDTO(
            id: 2001,
            name: "Evening Run",
            distance: 4083.4,
            movingTime: 1800,
            elapsedTime: 1950,
            totalElevationGain: 44.0,
            sportType: "Run",
            averageSpeed: 3.2,
            maxSpeed: 5.8,
            averageHeartRate: 148.0,
            maxHeartRate: 172.0
        )
    )

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
        "heartrate": {
            "data": [145, 151],
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

    await api.setActivityStreams(
        Array(streamSet.values)
    )

    let repository = StravaActivityRepository(
        api: api
    )

    let activity = try await repository.fetchActivity(
        id: "2001"
    )

    #expect(activity.id == "2001")
    #expect(activity.name == "Evening Run")

    #expect(activity.distance == 4083.4)
    #expect(activity.elevationGain == 44.0)

    #expect(activity.averageSpeed == 3.2)
    #expect(activity.maximumSpeed == 5.8)

    #expect(activity.averageHeartRate == 148.0)
    #expect(activity.maximumHeartRate == 172.0)

    #expect(activity.points.count == 2)

    #expect(activity.points[0].trackPoint.latitude == 47.6500)
    #expect(activity.points[0].trackPoint.altitude == 312.0)
    #expect(activity.points[0].heartRate == 145)

    #expect(activity.points[1].trackPoint.distance == 125.0)
    #expect(activity.points[1].trackPoint.altitude == 318.0)
    #expect(activity.points[1].heartRate == 151)
}

@Test
func fetchActivityWithInvalidIDThrowsError() async {
    let api = MockActivityStravaAPI()

    let repository = StravaActivityRepository(
        api: api
    )

    do {
        _ = try await repository.fetchActivity(
            id: "invalid-id"
        )

        Issue.record(
            "Expected invalidActivityID error"
        )
    } catch let error as StravaRepositoryError {
        #expect(error == .invalidActivityID)
    } catch {
        Issue.record(
            "Unexpected error: \(error)"
        )
    }
}
