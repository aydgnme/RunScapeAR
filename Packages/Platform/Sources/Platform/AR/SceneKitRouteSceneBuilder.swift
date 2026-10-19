import Domain
import SceneKit

public struct SceneKitRouteSceneBuilder: Sendable {
    private let projector: TrackPointProjector
    private let normalizer: RouteNormalizer
    private let segmentBuilder: RouteSegmentBuilder
    private let routeFactory: SceneKitRouteFactory

    public init(
        projector: TrackPointProjector = TrackPointProjector(),
        normalizer: RouteNormalizer = RouteNormalizer(),
        segmentBuilder: RouteSegmentBuilder = RouteSegmentBuilder(),
        routeFactory: SceneKitRouteFactory = SceneKitRouteFactory()
    ) {
        self.projector = projector
        self.normalizer = normalizer
        self.segmentBuilder = segmentBuilder
        self.routeFactory = routeFactory
    }

    @MainActor
    public func makeNode(
        from points: [TrackPoint]
    ) -> SCNNode {
        let projectedPoints = projector.project(points)
        let normalizedPoints = normalizer.normalize(
            projectedPoints
        )
        let segments = segmentBuilder.build(
            from: normalizedPoints
        )
        return routeFactory.makeNode(from: segments)
    }
}
