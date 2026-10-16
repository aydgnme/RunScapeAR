//
//  StravaRouteMapper.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Domain

struct StravaRouteMapper: Sendable {
    func summary(
        from dto: StravaRouteDTO
    ) -> RouteSummary {
        RouteSummary(
            id: String(dto.id),
            name: dto.name,
            distance: dto.distance,
            elevationGain: dto.elevationGain
        )
    }

    func route(
        from dto: StravaRouteDTO,
        points: [TrackPoint]
    ) -> Route {
        Route(
            id: String(dto.id),
            name: dto.name,
            distance: dto.distance,
            elevationGain: dto.elevationGain,
            points: points
        )
    }
}
