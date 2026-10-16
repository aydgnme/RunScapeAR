//
//  RouteTests.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import Domain
import Testing

@Test
func routeStoresRouteInformation() {
    let points = [
        TrackPoint(
            latitude: 47.44,
            longitude: 25.56,
            altitude: 792,
            distance: 0
        ),
        TrackPoint(
            latitude: 47.45,
            longitude: 25.57,
            altitude: 814,
            distance: 150
        )
    ]

    let route = Route(
        id: "route-1",
        name: "Rarau Trail",
        distance: 14820,
        elevationGain: 821,
        points: points
    )

    #expect(route.id == "route-1")
    #expect(route.name == "Rarau Trail")
    #expect(route.distance == 14820)
    #expect(route.elevationGain == 821)
    #expect(route.points.count == 2)
}
