//
//  ARRouteCameraView.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import ARKit
import Domain
import Platform
import RealityKit
import SwiftUI

@MainActor
struct ARRouteCameraView: UIViewRepresentable {
    let points: [TrackPoint]

    @Binding var instruction: String

    func makeCoordinator() -> Coordinator {
        Coordinator(
            points: points,
            instruction: $instruction
        )
    }

    func makeUIView(
        context: Context
    ) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )

        let configuration =
            ARWorldTrackingConfiguration()

        configuration.planeDetection = [
            .horizontal
        ]

        arView.session.run(
            configuration,
            options: [
                .resetTracking,
                .removeExistingAnchors
            ]
        )

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                Coordinator.handleTap(_:)
            )
        )

        arView.addGestureRecognizer(
            tapGesture
        )

        context.coordinator.arView =
            arView

        return arView
    }

    func updateUIView(
        _ uiView: ARView,
        context: Context
    ) {}

    static func dismantleUIView(
        _ uiView: ARView,
        coordinator: Coordinator
    ) {
        uiView.session.pause()
    }

    @MainActor
    final class Coordinator: NSObject {
        weak var arView: ARView?

        private let points: [TrackPoint]
        private var instruction: Binding<String>
        private var routeWasPlaced = false

        init(
            points: [TrackPoint],
            instruction: Binding<String>
        ) {
            self.points = points
            self.instruction = instruction
        }

        @objc
        func handleTap(
            _ gesture: UITapGestureRecognizer
        ) {
            guard
                !routeWasPlaced,
                let arView
            else {
                return
            }

            let location = gesture.location(
                in: arView
            )

            guard let result =
                arView.raycast(
                    from: location,
                    allowing: .existingPlaneInfinite,
                    alignment: .horizontal
                ).first
            else {
                return
            }

            placeRoute(
                using: result
            )
        }

        private func placeRoute(
            using result: ARRaycastResult
        ) {
            guard let arView else {
                return
            }

            let anchor = AnchorEntity(
                world: result.worldTransform
            )

            let routeEntity =
                RouteSceneBuilder()
                    .makeEntity(
                        from: points
                    )

            anchor.addChild(
                routeEntity
            )

            arView.scene.addAnchor(
                anchor
            )

            routeWasPlaced = true

            instruction.wrappedValue =
                "Route placed"
        }
    }
}
