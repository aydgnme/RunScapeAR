//
//  RouteNormalizerTests.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

@testable import Platform
import Testing

@Test
func normalizedRouteFitsTargetHorizontalSize() throws {
    let points = [
        LocalPoint3D(
            x: 0,
            y: 0,
            z: 0
        ),
        LocalPoint3D(
            x: 1000,
            y: 100,
            z: 500
        )
    ]

    let result = RouteNormalizer(
        targetHorizontalSize: 0.7,
        elevationExaggeration: 1.0
    ).normalize(points)

    let minX = try #require(result.map(\.x).min())
    let maxX = try #require(result.map(\.x).max())

    #expect(abs((maxX - minX) - 0.7) < 0.000_001)
}

@Test
func normalizedRouteIsCenteredHorizontally() throws {
    let points = [
        LocalPoint3D(
            x: 100,
            y: 20,
            z: 200
        ),
        LocalPoint3D(
            x: 300,
            y: 40,
            z: 600
        )
    ]

    let result = RouteNormalizer().normalize(
        points
    )

    let minX = try #require(result.map(\.x).min())
    let maxX = try #require(result.map(\.x).max())

    let minZ = try #require(result.map(\.z).min())
    let maxZ = try #require(result.map(\.z).max())

    #expect(abs(minX + maxX) < 0.000_001)
    #expect(abs(minZ + maxZ) < 0.000_001)
}

@Test
func lowestElevationBecomesZero() {
    let points = [
        LocalPoint3D(
            x: 0,
            y: -20,
            z: 0
        ),
        LocalPoint3D(
            x: 100,
            y: 30,
            z: 100
        )
    ]

    let result = RouteNormalizer().normalize(
        points
    )

    let minimumElevation = result.map(\.y).min()

    #expect(minimumElevation == 0)
}
