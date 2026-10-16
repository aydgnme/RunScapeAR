//
//  RouteSceneBuilderTests.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
@testable import Platform
import Testing

@Test
@MainActor
func routeSceneBuilderCreatesRenderableRoute() {
    let points = [
        TrackPoint(
            latitude: 47.6500,
            longitude: 26.2500,
            altitude: 312,
            distance: 0
        ),
        TrackPoint(
            latitude: 47.6510,
            longitude: 26.2510,
            altitude: 318,
            distance: 150
        ),
        TrackPoint(
            latitude: 47.6520,
            longitude: 26.2520,
            altitude: 325,
            distance: 300
        )
    ]

    let entity = RouteSceneBuilder().makeEntity(
        from: points
    )

    #expect(entity.children.count == 2)
}

@Test
@MainActor
func emptyRouteCreatesEmptyEntity() {
    let entity = RouteSceneBuilder().makeEntity(
        from: []
    )

    #expect(entity.children.isEmpty)
}
