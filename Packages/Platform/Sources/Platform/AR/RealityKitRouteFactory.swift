//
//  RealityKitRouteFactory.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import RealityKit
import simd

public struct RealityKitRouteFactory: Sendable {
    public let radius: Float

    public init(
        radius: Float = 0.003
    ) {
        self.radius = radius
    }

    @MainActor
    public func makeEntity(
        from segments: [RouteSegment]
    ) -> Entity {
        let root = Entity()

        for segment in segments {
            guard segment.length > 0 else {
                continue
            }

            let entity = makeSegmentEntity(
                from: segment
            )

            root.addChild(entity)
        }

        return root
    }

    @MainActor
    private func makeSegmentEntity(
        from segment: RouteSegment
    ) -> ModelEntity {
        let start = vector(
            from: segment.start
        )

        let end = vector(
            from: segment.end
        )

        let direction = end - start
        let length = simd_length(direction)

        let thickness = radius * 2

        let mesh = MeshResource.generateBox(
            size: SIMD3<Float>(
                thickness,
                length,
                thickness
            ),
            cornerRadius: radius
        )

        let matrial = SimpleMaterial(
            color: .orange,
            roughness: 0.6,
            isMetallic: false
        )

        let entity = ModelEntity(
            mesh: mesh,
            materials: [matrial]
        )

        entity.position = (
            start + end
        ) / 2

        entity.orientation = rotation(
            direction: direction
        )

        return entity
    }

    private func vector(
        from point: LocalPoint3D
    ) -> SIMD3<Float> {
        SIMD3<Float>(
            Float(point.x),
            Float(point.y),
            Float(point.z)
        )
    }

    private func rotation(
        direction: SIMD3<Float>
    ) -> simd_quatf {
        let normalizedDirection = simd_normalize(
            direction
        )

        return simd_quatf(
            from: SIMD3<Float>(
                0,
                1,
                0
            ),
            to: normalizedDirection
        )
    }
}
