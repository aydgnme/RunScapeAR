//
//  RouteSceneBuilder.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import RealityKit

public struct RouteSceneBuilder: Sendable {
    private let projector: TrackPointProjector
    private let normalizer: RouteNormalizer
    private let segmentBuilder: RouteSegmentBuilder
    private let routeFactory: RealityKitRouteFactory

    public init(
        projector: TrackPointProjector = TrackPointProjector(),
        normalizer: RouteNormalizer = RouteNormalizer(),
        segmentBuilder: RouteSegmentBuilder = RouteSegmentBuilder(),
        routeFactory: RealityKitRouteFactory = RealityKitRouteFactory()
    ) {
        self.projector = projector
        self.normalizer = normalizer
        self.segmentBuilder = segmentBuilder
        self.routeFactory = routeFactory
    }

    @MainActor
    public func makeEntity(
        from points: [TrackPoint]
    ) -> Entity {
        let projectedPoints = projector.project(
            points
        )

        let normalizedPoints = normalizer.normalize(
            projectedPoints
        )

        let segments = segmentBuilder.build(
            from: normalizedPoints
        )

        return routeFactory.makeEntity(
            from: segments
        )
    }
}
