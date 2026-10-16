//
//  RoutePreviewView.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import Platform
import RealityKit
import SwiftUI

@MainActor
struct RoutePreviewView: UIViewRepresentable {
    func makeUIView(
        context: Context
    ) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )

        let anchor = AnchorEntity(
            world: .zero
        )

        let routeEntity = RouteSceneBuilder()
            .makeEntity(
                from: Self.previewPoints
            )

        anchor.addChild(
            routeEntity
        )

        let camera = PerspectiveCamera()

        camera.look(
            at: SIMD3<Float>(
                0,
                0.05,
                0
            ),
            from: SIMD3<Float>(
                0,
                0.55,
                1.0
            ),
            relativeTo: nil
        )

        anchor.addChild(
            camera
        )

        arView.scene.addAnchor(
            anchor
        )

        return arView
    }

    func updateUIView(
        _ uiView: ARView,
        context: Context
    ) {}

    private static let previewPoints: [TrackPoint] = [
        TrackPoint(
            latitude: 47.6500,
            longitude: 26.2500,
            altitude: 312,
            distance: 0
        ),
        TrackPoint(
            latitude: 47.6504,
            longitude: 26.2503,
            altitude: 316,
            distance: 60
        ),
        TrackPoint(
            latitude: 47.6508,
            longitude: 26.2510,
            altitude: 323,
            distance: 130
        ),
        TrackPoint(
            latitude: 47.6511,
            longitude: 26.2518,
            altitude: 319,
            distance: 210
        ),
        TrackPoint(
            latitude: 47.6516,
            longitude: 26.2521,
            altitude: 331,
            distance: 300
        )
    ]
}
