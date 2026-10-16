//
//  StravaRouteRepositoryTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Foundation
import Testing

private actor MockStravaAPI: StravaAPI {
    var athlete = StravaAthleteDTO(
        id: 42,
        username: "mertaydogan",
        firstName: "Mert",
        lastName: "Aydogan"
    )

    var routesResult: [StravaRouteDTO] = []
    var routeResult: StravaRouteDTO?
    var streamsResult: [StravaStreamDTO] = []
    var activityResult: StravaActivityDTO?
    var activitiesResult: [StravaActivitySummaryDTO] = []
    var activityStreamsResult: [StravaStreamDTO] = []

    func authenticatedAthlete() async throws -> StravaAthleteDTO {
        athlete
    }

    func routes(
        athleteID: Int64,
        page: Int,
        perPage: Int
    ) async throws -> [StravaRouteDTO] {
        routesResult
    }

    func route(
        id: Int64
    ) async throws -> StravaRouteDTO {
        guard let routeResult else {
            fatalError("routeResult not configured")
        }

        return routeResult
    }

    func routeStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO] {
        streamsResult
    }

    func activityStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO] {
        activityStreamsResult
    }

    func activity(
        id: Int64
    ) async throws -> StravaActivityDTO {
        guard let activityResult else {
            fatalError("activityResult not configured")
        }

        return activityResult
    }

    func activities(
        page: Int,
        perPage: Int
    ) async throws -> [StravaActivitySummaryDTO] {
        activitiesResult
    }

    func setRoutes(
        _ routes: [StravaRouteDTO]
    ) {
        routesResult = routes
    }

    func setRoute(
        _ route: StravaRouteDTO
    ) {
        routeResult = route
    }

    func setStreams(
        _ streams: [StravaStreamDTO]
    ) {
        streamsResult = streams
    }
}

@Test
func fetchRoutesMapsStravaRoutesToDomainSummaries() async throws {
    let api = MockStravaAPI()

    await api.setRoutes([
        StravaRouteDTO(
            id: 1001,
            name: "Mountain Run",
            distance: 12500,
            elevationGain: 640
        )
    ])

    let repository = StravaRouteRepository(
        api: api
    )

    let routes = try await repository.fetchRoutes()

    #expect(routes.count == 1)
    #expect(routes[0].id == "1001")
    #expect(routes[0].name == "Mountain Run")
    #expect(routes[0].distance == 12500)
    #expect(routes[0].elevationGain == 640)
}

@Test
// swiftlint:disable:next function_body_length
func fetchRouteMapsRouteAndStreamsToDomainRoute() async throws {
    let api = MockStravaAPI()

    await api.setRoute(
        StravaRouteDTO(
            id: 1001,
            name: "Mountain Run",
            distance: 12500,
            elevationGain: 640
        )
    )

    let json = """
    [
        {
            "type": "latlng",
            "data": [
                [47.4400, 25.5600],
                [47.4410, 25.5610]
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        {
            "type": "distance",
            "data": [
                0.0,
                150.0
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        {
            "type": "altitude",
            "data": [
                792.0,
                814.0
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        }
    ]
    """

    let streams = try JSONDecoder().decode(
        [StravaStreamDTO].self,
        from: Data(json.utf8)
    )

    await api.setStreams(streams)

    let repository = StravaRouteRepository(
        api: api
    )

    let route = try await repository.fetchRoute(
        id: "1001"
    )

    #expect(route.id == "1001")
    #expect(route.name == "Mountain Run")
    #expect(route.distance == 12500)
    #expect(route.elevationGain == 640)

    #expect(route.points.count == 2)

    #expect(route.points[0].latitude == 47.4400)
    #expect(route.points[0].longitude == 25.5600)
    #expect(route.points[0].altitude == 792.0)
    #expect(route.points[0].distance == 0)

    #expect(route.points[1].altitude == 814.0)
    #expect(route.points[1].distance == 150)
}

@Test
func fetchRouteWithInvalidIDThrowsError() async {
    let api = MockStravaAPI()

    let repository = StravaRouteRepository(
        api: api
    )

    do {
        _ = try await repository.fetchRoute(
            id: "invalid-id"
        )

        Issue.record(
            "Expected invalidRouteID error"
        )
    } catch let error as StravaRepositoryError {
        #expect(error == .invalidRouteID)
    } catch {
        Issue.record(
            "Unexpected error: \(error)"
        )
    }
}
