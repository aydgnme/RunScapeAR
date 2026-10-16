//
//  StravaAPI.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

protocol StravaAPI: Sendable {
    func authenticatedAthlete() async throws -> StravaAthleteDTO

    func route(
        id: Int64
    ) async throws -> StravaRouteDTO

    func routes(
        athleteID: Int64,
        page: Int,
        perPage: Int
    ) async throws -> [StravaRouteDTO]

    func routeStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO]

    func activity(
        id: Int64
    ) async throws -> StravaActivityDTO

    func activities(
        page: Int,
        perPage: Int
    ) async throws -> [StravaActivitySummaryDTO]

    func activityStreams(
        id: Int64
    ) async throws -> [StravaStreamDTO]
}
