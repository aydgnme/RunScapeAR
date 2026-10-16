//
//  StravaRouteRepository.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Domain

public final class StravaRouteRepository:
    RouteRepository,
    @unchecked Sendable
{
    private let api: any StravaAPI

    private let routeMapper: StravaRouteMapper
    private let streamMapper: StravaRouteStreamMapper

    public convenience init(
        client: StravaClient
    ) {
        self.init(
            api: client,
            routeMapper: StravaRouteMapper(),
            streamMapper: StravaRouteStreamMapper()
        )
    }

    init(
        api: any StravaAPI,
        routeMapper: StravaRouteMapper = StravaRouteMapper(),
        streamMapper: StravaRouteStreamMapper = StravaRouteStreamMapper()
    ) {
        self.api = api
        self.routeMapper = routeMapper
        self.streamMapper = streamMapper
    }

    public func fetchRoutes() async throws -> [RouteSummary] {
        let athlete = try await api.authenticatedAthlete()

        let routes = try await api.routes(
            athleteID: athlete.id,
            page: 1,
            perPage: 30
        )

        return routes.map {
            routeMapper.summary(from: $0)
        }
    }

    public func fetchRoute(
        id: String
    ) async throws -> Route {
        guard let routeID = Int64(id) else {
            throw StravaRepositoryError.invalidRouteID
        }

        async let routeRequest = api.route(
            id: routeID
        )

        async let streamsRequest = api.routeStreams(
            id: routeID
        )

        let (routeDTO, streams) = try await (
            routeRequest,
            streamsRequest
        )

        let points = try streamMapper.map(streams)

        return routeMapper.route(
            from: routeDTO,
            points: points
        )
    }
}
