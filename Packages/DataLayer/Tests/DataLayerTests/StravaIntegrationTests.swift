//
//  StravaIntegrationTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Foundation
import Testing

private let runStravaIntegrationTests =
    ProcessInfo.processInfo.environment[
        "RUN_STRAVA_INTEGRATION_TESTS"
    ] == "1"

private struct EnvironmentTokenProvider: AccessTokenProvider {
    func accessToken() async throws -> String {
        guard
            let token = ProcessInfo.processInfo.environment[
                "STRAVA_ACCESS_TOKEN"
            ],
            !token.isEmpty
        else {
            throw IntegrationTestError.missingAccessToken
        }

        return token
    }
}

private enum IntegrationTestError: Error {
    case missingAccessToken
}

@Test(
    .enabled(if: runStravaIntegrationTests)
)
func authenticatedAthleteCanBeDecodedFromStrava() async throws {
    let client = StravaClient(
        httpClient: URLSessionHTTPClient(),
        tokenProvider: EnvironmentTokenProvider()
    )

    let athlete = try await client.get(
        .authenticatedAthlete,
        as: StravaAthleteDTO.self
    )

    #expect(athlete.id > 0)
}

@Test(
    .enabled(if: runStravaIntegrationTests)
)
func athleteRoutesCanBeDecodedFromStrava() async throws {
    let client = StravaClient(
        httpClient: URLSessionHTTPClient(),
        tokenProvider: EnvironmentTokenProvider()
    )

    let athlete = try await client.get(
        .authenticatedAthlete,
        as: StravaAthleteDTO.self
    )

    let routes = try await client.get(
        .athleteRoutes(
            athleteID: athlete.id,
            page: 1,
            perPage: 30
        ),
        as: [StravaRouteDTO].self
    )

    for route in routes {
        print(
            "\(route.name) | \(route.distance)m | +\(route.elevationGain)m"
        )
    }

    #expect(!routes.isEmpty)
}

@Test(
    .enabled(if: runStravaIntegrationTests)
)
func routeStreamsCanBeDecodedFromStrava() async throws {
    let client = StravaClient(
        httpClient: URLSessionHTTPClient(),
        tokenProvider: EnvironmentTokenProvider()
    )

    let athlete = try await client.get(
        .authenticatedAthlete,
        as: StravaAthleteDTO.self
    )

    let routes = try await client.get(
        .athleteRoutes(
            athleteID: athlete.id,
            page: 1,
            perPage: 30
        ),
        as: [StravaRouteDTO].self
    )

    guard let route = routes.first else {
        return
    }

    let streams = try await client.get(
        .routeStreams(id: route.id),
        as: [StravaStreamDTO].self
    )

    #expect(!streams.isEmpty)
}

@Test(
    .enabled(if: runStravaIntegrationTests)
)
func athleteActivitiesCanBeDecodedFromStrava() async throws {
    let client = StravaClient(
        httpClient: URLSessionHTTPClient(),
        tokenProvider: EnvironmentTokenProvider()
    )

    let activities = try await client.activities(
        page: 1,
        perPage: 30
    )

    for activity in activities {
        print(
            "\(activity.sportType) | " +
                "\(activity.name) | " +
                "\(activity.distance)m | " +
                "+\(activity.totalElevationGain)m"
        )
    }
}

@Test(
    .enabled(if: runStravaIntegrationTests)
)
func activityDetailCanBeDecodedFromStrava() async throws {
    let client = StravaClient(
        httpClient: URLSessionHTTPClient(),
        tokenProvider: EnvironmentTokenProvider()
    )

    let activities = try await client.activities(
        page: 1,
        perPage: 30
    )

    let firstActivity = try #require(
        activities.first
    )

    let activity = try await client.activity(
        id: firstActivity.id
    )

    #expect(activity.id == firstActivity.id)
    #expect(activity.name == firstActivity.name)
}

@Test(
    .enabled(if: runStravaIntegrationTests)
)
func activityStreamsCanBeDecodedFromStrava() async throws {
    let client = StravaClient(
        httpClient: URLSessionHTTPClient(),
        tokenProvider: EnvironmentTokenProvider()
    )

    let activities = try await client.activities(
        page: 1,
        perPage: 30
    )

    let activity = try #require(
        activities.first {
            $0.sportType == "Run"
                && $0.distance > 0
        }
    )

    let streams = try await client.activityStreams(
        id: activity.id
    )

    #expect(!streams.isEmpty)
    #expect(
        streams.contains {
            $0.type == "distance"
        }
    )
}
