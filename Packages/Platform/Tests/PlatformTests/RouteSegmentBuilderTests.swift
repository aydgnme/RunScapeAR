//
//  RouteSegmentBuilderTests.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

@testable import Platform
import Testing

@Test
func routeSegmentsAreBuiltBetweenConsecutivePoints() {
    let points = [
        LocalPoint3D(
            x: 0,
            y: 0,
            z: 0
        ),
        LocalPoint3D(
            x: 1,
            y: 0,
            z: 0
        ),
        LocalPoint3D(
            x: 2,
            y: 1,
            z: 0
        )
    ]

    let segments = RouteSegmentBuilder().build(
        from: points
    )

    #expect(segments.count == 2)

    #expect(segments[0].start == points[0])
    #expect(segments[0].end == points[1])

    #expect(segments[1].start == points[1])
    #expect(segments[1].end == points[2])
}

@Test
func routeSegmentCalculatesLength() {
    let segment = RouteSegment(
        start: LocalPoint3D(
            x: 0,
            y: 0,
            z: 0
        ),
        end: LocalPoint3D(
            x: 3,
            y: 4,
            z: 0
        )
    )

    #expect(segment.length == 5)
}

@Test
func routeSegmentCalculatesMidpoint() {
    let segment = RouteSegment(
        start: LocalPoint3D(
            x: -1,
            y: 0,
            z: -2
        ),
        end: LocalPoint3D(
            x: 1,
            y: 2,
            z: 2
        )
    )

    #expect(
        segment.midpoint
            == LocalPoint3D(
                x: 0,
                y: 1,
                z: 0
            )
    )
}

@Test
func fewerThanTwoPointsProduceNoSegments() {
    let segments = RouteSegmentBuilder().build(
        from: [
            LocalPoint3D(
                x: 0,
                y: 0,
                z: 0
            )
        ]
    )

    #expect(segments.isEmpty)
}
