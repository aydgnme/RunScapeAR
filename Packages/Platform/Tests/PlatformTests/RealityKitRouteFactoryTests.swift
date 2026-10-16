//
//  RealityKitRouteFactoryTests.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

@testable import Platform
import RealityKit
import Testing

@Test
@MainActor
func routeFactoryCreatesEntityForEachSegment() {
    let segments = [
        RouteSegment(
            start: LocalPoint3D(
                x: 0,
                y: 0,
                z: 0
            ),
            end: LocalPoint3D(
                x: 0.2,
                y: 0.05,
                z: -0.2
            )
        ),
        RouteSegment(
            start: LocalPoint3D(
                x: 0.2,
                y: 0.05,
                z: -0.2
            ),
            end: LocalPoint3D(
                x: 0.4,
                y: 0.08,
                z: -0.1
            )
        )
    ]

    let entity = RealityKitRouteFactory().makeEntity(
        from: segments
    )

    #expect(entity.children.count == 2)
}

@Test
@MainActor
func zeroLengthSegmentIsIgnored() {
    let point = LocalPoint3D(
        x: 0,
        y: 0,
        z: 0
    )

    let entity = RealityKitRouteFactory().makeEntity(
        from: [
            RouteSegment(
                start: point,
                end: point
            )
        ]
    )

    #expect(entity.children.isEmpty)
}
