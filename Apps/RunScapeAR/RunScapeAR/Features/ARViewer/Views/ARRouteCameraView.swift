import ARKit
import Domain
import Platform
import SceneKit
import SwiftUI

@MainActor
struct ARRouteCameraView: UIViewRepresentable {
    let points: [TrackPoint]
    let resetRequestID: Int
    let isActive: Bool

    @Binding var instruction: String
    @Binding var isPlaced: Bool
    @Binding var surfaceReady: Bool

    func makeCoordinator() -> ARRouteCameraCoordinator {
        ARRouteCameraCoordinator(
            points: points,
            instruction: $instruction,
            isPlaced: $isPlaced,
            surfaceReady: $surfaceReady
        )
    }

    func makeUIView(context: Context) -> ARSCNView {
        let scnView = ARSCNView(frame: .zero)
        scnView.automaticallyUpdatesLighting = true

        let configuration =
            ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        scnView.session.run(
            configuration,
            options: [
                .resetTracking,
                .removeExistingAnchors
            ]
        )

        let coaching = ARCoachingOverlayView()
        coaching.session = scnView.session
        coaching.goal = .horizontalPlane
        coaching.activatesAutomatically = true
        coaching.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        scnView.addSubview(coaching)

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                ARRouteCameraCoordinator.handleTap(_:)
            )
        )
        scnView.addGestureRecognizer(tap)

        context.coordinator.scnView = scnView
        context.coordinator.startScanning()

        return scnView
    }

    func updateUIView(
        _ uiView: ARSCNView,
        context: Context
    ) {
        let coordinator = context.coordinator

        if resetRequestID != coordinator.lastProcessedResetID {
            coordinator.lastProcessedResetID =
                resetRequestID
            Task { @MainActor in
                coordinator.handleReposition()
            }
        }

        coordinator.handleActiveChange(
            isActive, scnView: uiView
        )
    }

    static func dismantleUIView(
        _ uiView: ARSCNView,
        coordinator: ARRouteCameraCoordinator
    ) {
        coordinator.stopAll()
        uiView.session.pause()
    }
}

#Preview {
    ARRouteCameraView(
        points: PreviewData.trackPoints,
        resetRequestID: 0,
        isActive: true,
        instruction: .constant("Route placed"),
        isPlaced: .constant(false),
        surfaceReady: .constant(false)
    )
}
