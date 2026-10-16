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
    let points: [TrackPoint]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

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
                from: points
            )

        anchor.addChild(
            routeEntity
        )

        let camera = PerspectiveCamera()

        anchor.addChild(
            camera
        )

        arView.scene.addAnchor(
            anchor
        )

        context.coordinator.camera = camera
        context.coordinator.updateCamera()

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                Coordinator.handlePan(_:)
            )
        )

        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                Coordinator.handlePinch(_:)
            )
        )

        arView.addGestureRecognizer(
            panGesture
        )

        arView.addGestureRecognizer(
            pinchGesture
        )

        return arView
    }

    func updateUIView(
        _ uiView: ARView,
        context: Context
    ) {}

    @MainActor
    final class Coordinator: NSObject {
        var camera: PerspectiveCamera?

        private var yaw: Float = 0
        private var pitch: Float = 0.45
        private var distance: Float = 1.0

        private let target = SIMD3<Float>(
            0,
            0.05,
            0
        )

        @objc
        func handlePan(
            _ gesture: UIPanGestureRecognizer
        ) {
            let translation = gesture.translation(
                in: gesture.view
            )

            yaw -= Float(
                translation.x
            ) * 0.005

            pitch += Float(
                translation.y
            ) * 0.005

            pitch = min(
                max(pitch, 0.1),
                1.4
            )

            gesture.setTranslation(
                .zero,
                in: gesture.view
            )

            updateCamera()
        }

        @objc
        func handlePinch(
            _ gesture: UIPinchGestureRecognizer
        ) {
            distance /= Float(
                gesture.scale
            )

            distance = min(
                max(distance, 0.35),
                2.5
            )

            gesture.scale = 1

            updateCamera()
        }

        func updateCamera() {
            guard let camera else {
                return
            }

            let horizontalDistance =
                distance * cos(pitch)

            let position = SIMD3<Float>(
                horizontalDistance * sin(yaw),
                distance * sin(pitch),
                horizontalDistance * cos(yaw)
            )

            camera.look(
                at: target,
                from: position,
                relativeTo: nil
            )
        }
    }
}
