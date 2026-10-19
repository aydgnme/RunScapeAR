import SceneKit
import simd

public struct SceneKitRouteFactory: Sendable {
    public let radius: Float

    public init(radius: Float = 0.003) {
        self.radius = radius
    }

    @MainActor
    public func makeNode(
        from segments: [RouteSegment]
    ) -> SCNNode {
        let root = SCNNode()

        let material = SCNMaterial()
        material.diffuse.contents = CGColor(
            red: 1.0,
            green: 0.5,
            blue: 0.0,
            alpha: 1.0
        )
        material.roughness.contents = 0.6

        for segment in segments {
            guard segment.length > 0 else { continue }
            let node = makeSegmentNode(
                from: segment,
                material: material
            )
            root.addChildNode(node)
        }

        return root
    }

    private func makeSegmentNode(
        from segment: RouteSegment,
        material: SCNMaterial
    ) -> SCNNode {
        let start = vector(from: segment.start)
        let end = vector(from: segment.end)
        let direction = end - start
        let length = simd_length(direction)

        let thickness = CGFloat(radius * 2)

        let box = SCNBox(
            width: thickness,
            height: CGFloat(length),
            length: thickness,
            chamferRadius: CGFloat(radius)
        )
        box.materials = [material]

        let node = SCNNode(geometry: box)
        node.simdPosition = (start + end) / 2
        node.simdOrientation = rotation(
            direction: direction
        )

        return node
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
        let normalized = simd_normalize(direction)
        return simd_quatf(
            from: SIMD3<Float>(0, 1, 0),
            to: normalized
        )
    }
}
