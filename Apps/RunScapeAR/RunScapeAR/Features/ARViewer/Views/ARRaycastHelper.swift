import ARKit
import SceneKit
import simd

@MainActor
enum ARRaycastHelper {
    static func rayOrigin(frame: ARFrame) -> SIMD3<Float> {
        let transform = frame.camera.transform
        return SIMD3(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }

    static func rayDirection(
        from point: CGPoint,
        in view: ARSCNView,
        frame: ARFrame
    ) -> SIMD3<Float> {
        let camera = frame.camera
        let viewport = view.bounds.size

        let intrinsics = camera.intrinsics
        let fx = intrinsics[0][0]
        let fy = intrinsics[1][1]
        let cx = intrinsics[2][0]
        let cy = intrinsics[2][1]

        let imgW = Float(camera.imageResolution.width)
        let imgH = Float(camera.imageResolution.height)
        let vpW = Float(viewport.width)
        let vpH = Float(viewport.height)

        let px = Float(point.x) * imgW / vpW
        let py = Float(point.y) * imgH / vpH

        let localRay = SIMD3<Float>(
            (px - cx) / fx,
            -(py - cy) / fy,
            -1.0
        )

        let rotation = simd_float3x3(
            SIMD3(
                camera.transform.columns.0.x,
                camera.transform.columns.0.y,
                camera.transform.columns.0.z
            ),
            SIMD3(
                camera.transform.columns.1.x,
                camera.transform.columns.1.y,
                camera.transform.columns.1.z
            ),
            SIMD3(
                camera.transform.columns.2.x,
                camera.transform.columns.2.y,
                camera.transform.columns.2.z
            )
        )

        return simd_normalize(rotation * localRay)
    }
}
