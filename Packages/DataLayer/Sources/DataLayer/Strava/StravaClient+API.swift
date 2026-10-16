//
//  StravaClient+API.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

extension StravaClient: StravaAPI {
    func authenticatedAthlete() async throws -> StravaAthleteDTO {
        try await get(
            .authenticatedAthlete,
            as: StravaAthleteDTO.self
        )
    }

    func route(
        id: Int64
    ) async throws -> StravaRouteDTO {
        try await get(
            .route(id: id),
            as: StravaRouteDTO.self
        )
    }

    func routes(
        athleteID: Int64,
        page: Int,
        perPage: Int
    ) async throws -> [StravaRouteDTO] {
        try await get(
            .athleteRoutes(
                athleteID: athleteID,
                page: page,
                perPage: perPage
            ),
            as: [StravaRouteDTO].self
        )
    }

    func routeStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO] {
        try await get(
            .routeStreams(id: id),
            as: [StravaStreamDTO].self
        )
    }

    func activity(id: Int64) async throws -> StravaActivityDTO {
        try await get(.activity(id: id), as: StravaActivityDTO.self)
    }

    func activities(page: Int, perPage: Int) async throws -> [StravaActivitySummaryDTO] {
        try await get(
            .athleteActivities(page: page, perPage: perPage),
            as: [StravaActivitySummaryDTO].self
        )
    }

    func activityStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO] {
        let streamSet = try await get(
            .activityStreams(
                id: id,
                keys: [
                    "time",
                    "distance",
                    "latlng",
                    "altitude",
                    "velocity_smooth",
                    "heartrate",
                    "cadence",
                    "grade_smooth"
                ]
            ),
            as: [String: StravaStreamDTO].self
        )

        return Array(streamSet.values)
    }
}
