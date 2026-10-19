import ARKit
import Domain
import Platform
import RealityKit
import SwiftUI

@MainActor
struct ARRouteCameraView: UIViewRepresentable {
    let points: [TrackPoint]

    @Binding var instruction: String
    @Binding var isPlaced: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(
            points: points,
            instruction: $instruction,
            isPlaced: $isPlaced
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
    ) {
        context.coordinator.handleReset()
    }

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
        private var isPlaced: Binding<Bool>
        private var currentAnchor: AnchorEntity?
        private var pendingReset = false

        init(
            points: [TrackPoint],
            instruction: Binding<String>,
            isPlaced: Binding<Bool>
        ) {
            self.points = points
            self.instruction = instruction
            self.isPlaced = isPlaced
        }

        @objc
        func handleTap(
            _ gesture: UITapGestureRecognizer
        ) {
            guard
                !isPlaced.wrappedValue,
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
                instruction.wrappedValue =
                    "No surface detected. Try again."
                return
            }

            placeRoute(
                using: result
            )
        }

        func handleReset() {
            guard
                !isPlaced.wrappedValue,
                currentAnchor != nil
            else {
                return
            }

            removeRoute()
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

            currentAnchor = anchor
            isPlaced.wrappedValue = true

            instruction.wrappedValue =
                "Route placed"
        }

        private func removeRoute() {
            guard let arView, let anchor = currentAnchor else {
                return
            }

            arView.scene.removeAnchor(
                anchor
            )

            currentAnchor = nil

            instruction.wrappedValue =
                "Tap a surface to place the route"
        }
    }
}
