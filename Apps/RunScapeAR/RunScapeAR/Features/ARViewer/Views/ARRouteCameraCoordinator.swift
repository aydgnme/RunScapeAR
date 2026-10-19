import ARKit
import Domain
import Platform
import SceneKit
import SwiftUI

// swiftlint:disable type_body_length

@MainActor
final class ARRouteCameraCoordinator: NSObject {
    weak var scnView: ARSCNView?

    private let points: [TrackPoint]
    private let routeFootprint: (width: Float, depth: Float)
    private let surfaceFitter = SurfaceFitter()

    private var instruction: Binding<String>
    private var isPlaced: Binding<Bool>
    private var surfaceReady: Binding<Bool>

    private var routeNode: SCNNode?
    private var indicatorNode: SCNNode?
    private var scanTimer: Timer?
    private var phase: Phase = .scanning
    private var candidateStart: Date?

    var lastProcessedResetID = 0
    private var wasActive = true

    private let stabilityDuration: TimeInterval = 1.5

    #if DEBUG
        private var debugCube: SCNNode?
        private var diagnosticTimer: Timer?
    #endif

    enum Phase {
        case scanning
        case surfaceCandidate
        case placed
        case trackingLimited
    }

    init(
        points: [TrackPoint],
        instruction: Binding<String>,
        isPlaced: Binding<Bool>,
        surfaceReady: Binding<Bool>
    ) {
        self.points = points
        self.instruction = instruction
        self.isPlaced = isPlaced
        self.surfaceReady = surfaceReady

        let projector = TrackPointProjector()
        let normalizer = RouteNormalizer()
        let projected = projector.project(points)
        let normalized = normalizer.normalize(projected)
        let xs = normalized.map { Float($0.x) }
        let zs = normalized.map { Float($0.z) }
        routeFootprint = (
            width: (xs.max() ?? 0) - (xs.min() ?? 0),
            depth: (zs.max() ?? 0) - (zs.min() ?? 0)
        )
    }

    // MARK: - Scanning

    func startScanning() {
        stopAll()
        removeSurfaceIndicator()
        phase = .scanning
        candidateStart = nil

        let coordinator = self
        scanTimer = Timer.scheduledTimer(
            withTimeInterval: 0.2,
            repeats: true
        ) { _ in
            Task { @MainActor in
                coordinator.performScan()
            }
        }
    }

    func stopAll() {
        scanTimer?.invalidate()
        scanTimer = nil

        #if DEBUG
            diagnosticTimer?.invalidate()
            diagnosticTimer = nil
        #endif
    }

    private func performScan() {
        guard
            let scnView,
            scnView.bounds.width > 0,
            let frame = scnView.session.currentFrame
        else {
            return
        }

        if handleTrackingState(frame) {
            return
        }
        guard phase != .placed else { return }

        let center = CGPoint(
            x: scnView.bounds.midX,
            y: scnView.bounds.midY
        )

        let origin = ARRaycastHelper.rayOrigin(frame: frame)
        let direction = ARRaycastHelper.rayDirection(
            from: center, in: scnView, frame: frame
        )

        let estimatedHit = scnView.session.raycast(
            ARRaycastQuery(
                origin: origin,
                direction: direction,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )
        ).first

        let geometryHit = scnView.session.raycast(
            ARRaycastQuery(
                origin: origin,
                direction: direction,
                allowing: .existingPlaneGeometry,
                alignment: .horizontal
            )
        ).first

        guard estimatedHit != nil else {
            handleNoSurface()
            return
        }

        if phase == .scanning {
            transition(to: .surfaceCandidate)
        }

        if handleGeometryHit(geometryHit) {
            return
        }

        if let estimatedHit {
            updateSurfaceIndicator(
                at: estimatedHit.worldTransform,
                width: routeFootprint.width,
                depth: routeFootprint.depth
            )
        }

        candidateStart = nil
    }

    private func handleTrackingState(
        _ frame: ARFrame
    ) -> Bool {
        if frame.camera.trackingState != .normal {
            if phase != .trackingLimited,
               phase != .placed
            {
                transition(to: .trackingLimited)
                removeSurfaceIndicator()
                candidateStart = nil
            }
            return true
        }

        if phase == .trackingLimited {
            transition(to: .scanning)
        }
        return false
    }

    private func handleNoSurface() {
        removeSurfaceIndicator()
        if phase == .surfaceCandidate {
            transition(to: .scanning)
            candidateStart = nil
        }
    }

    private func handleGeometryHit(
        _ geometryHit: ARRaycastResult?
    ) -> Bool {
        guard
            let geometryHit,
            let planeAnchor = geometryHit.anchor as? ARPlaneAnchor
        else {
            return false
        }

        let planeW = planeAnchor.planeExtent.width
        let planeD = planeAnchor.planeExtent.height

        guard let fitScale = surfaceFitter.fit(
            routeWidth: routeFootprint.width,
            routeDepth: routeFootprint.depth,
            surfaceWidth: planeW,
            surfaceDepth: planeD
        ) else {
            return false
        }

        updateSurfaceIndicator(
            at: geometryHit.worldTransform,
            width: routeFootprint.width * fitScale,
            depth: routeFootprint.depth * fitScale
        )

        if candidateStart == nil {
            candidateStart = Date()
        }

        if let start = candidateStart,
           Date().timeIntervalSince(start) >= stabilityDuration
        {
            autoPlace(
                transform: geometryHit.worldTransform,
                scale: fitScale
            )
        }

        return true
    }

    // MARK: - Placement

    private func autoPlace(
        transform: simd_float4x4,
        scale: Float
    ) {
        guard let scnView else { return }

        stopAll()
        removeSurfaceIndicator()
        removeRoute()

        let routeRoot = SceneKitRouteSceneBuilder()
            .makeNode(from: points)
        routeRoot.simdScale = SIMD3(repeating: scale)

        let anchorNode = SCNNode()
        anchorNode.simdWorldTransform = transform
        anchorNode.addChildNode(routeRoot)

        #if DEBUG
            let cube = makeDebugCube()
            cube.simdPosition = SIMD3(0.1, 0.05, 0)
            anchorNode.addChildNode(cube)
            debugCube = cube
            startDiagnostics()
        #endif

        scnView.scene.rootNode.addChildNode(anchorNode)
        routeNode = anchorNode

        let anchor = ARAnchor(transform: transform)
        scnView.session.add(anchor: anchor)

        transition(to: .placed)
    }

    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        guard
            phase != .placed,
            let scnView,
            let frame = scnView.session.currentFrame
        else {
            return
        }

        let location = gesture.location(in: scnView)

        let results = scnView.session.raycast(
            ARRaycastQuery(
                origin: ARRaycastHelper.rayOrigin(frame: frame),
                direction: ARRaycastHelper.rayDirection(
                    from: location, in: scnView, frame: frame
                ),
                allowing: .existingPlaneGeometry,
                alignment: .horizontal
            )
        )

        if let result = results.first,
           let planeAnchor = result.anchor as? ARPlaneAnchor
        {
            let fitScale = surfaceFitter.fit(
                routeWidth: routeFootprint.width,
                routeDepth: routeFootprint.depth,
                surfaceWidth: planeAnchor.planeExtent.width,
                surfaceDepth: planeAnchor.planeExtent.height
            ) ?? 1.0

            autoPlace(
                transform: result.worldTransform,
                scale: fitScale
            )
        } else {
            instruction.wrappedValue =
                "No surface — point at a table and tap"
        }
    }

    func handleReposition() {
        removeRoute()
        instruction.wrappedValue = "Point at a flat surface"
        isPlaced.wrappedValue = false
        surfaceReady.wrappedValue = false
        startScanning()
    }

    func handleActiveChange(
        _ isActive: Bool,
        scnView: ARSCNView
    ) {
        if !isActive, wasActive {
            stopAll()
            scnView.session.pause()
        }

        if isActive, !wasActive {
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            scnView.session.run(config)

            if phase != .placed {
                startScanning()
            }
        }

        wasActive = isActive
    }

    private func removeRoute() {
        #if DEBUG
            diagnosticTimer?.invalidate()
            diagnosticTimer = nil
            debugCube = nil
        #endif

        routeNode?.removeFromParentNode()
        routeNode = nil
        candidateStart = nil
    }

    // MARK: - Surface indicator

    private func updateSurfaceIndicator(
        at transform: simd_float4x4,
        width: Float,
        depth: Float
    ) {
        guard let scnView else { return }

        if indicatorNode == nil {
            let plane = SCNPlane(width: 1.0, height: 1.0)
            let material = SCNMaterial()
            material.diffuse.contents = CGColor(
                red: 0, green: 1, blue: 0, alpha: 0.15
            )
            material.isDoubleSided = true
            plane.materials = [material]

            let node = SCNNode(geometry: plane)
            node.eulerAngles.x = -.pi / 2
            indicatorNode = SCNNode()
            indicatorNode!.addChildNode(node)
            scnView.scene.rootNode.addChildNode(
                indicatorNode!
            )
        }

        indicatorNode?.simdWorldTransform = transform
        indicatorNode?.childNodes.first?.simdScale =
            SIMD3(width, depth, 1.0)
    }

    private func removeSurfaceIndicator() {
        indicatorNode?.removeFromParentNode()
        indicatorNode = nil
    }

    // MARK: - State transitions

    private func transition(to newPhase: Phase) {
        guard phase != newPhase else { return }
        phase = newPhase

        switch newPhase {
        case .scanning:
            instruction.wrappedValue = "Point at a flat surface"
            isPlaced.wrappedValue = false
            surfaceReady.wrappedValue = false

        case .surfaceCandidate:
            instruction.wrappedValue = "Hold steady…"
            surfaceReady.wrappedValue = true

        case .placed:
            instruction.wrappedValue = "Route placed"
            isPlaced.wrappedValue = true
            surfaceReady.wrappedValue = false

        case .trackingLimited:
            instruction.wrappedValue =
                "Move slowly — tracking limited"
            surfaceReady.wrappedValue = false
        }
    }

    // MARK: - DEBUG diagnostics

    #if DEBUG
        private func makeDebugCube() -> SCNNode {
            let box = SCNBox(
                width: 0.1, height: 0.1,
                length: 0.1, chamferRadius: 0
            )
            let material = SCNMaterial()
            material.diffuse.contents = CGColor(
                red: 0, green: 1, blue: 0, alpha: 0.6
            )
            box.materials = [material]
            return SCNNode(geometry: box)
        }

        private func startDiagnostics() {
            diagnosticTimer?.invalidate()
            let coordinator = self
            diagnosticTimer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { _ in
                Task { @MainActor in
                    coordinator.logDiagnostics()
                }
            }
        }

        private func logDiagnostics() {
            guard
                let scnView,
                let frame = scnView.session.currentFrame,
                let routeNode
            else {
                return
            }

            let cameraTransform = frame.camera.transform
            let cameraPos = SIMD3(
                cameraTransform.columns.3.x,
                cameraTransform.columns.3.y,
                cameraTransform.columns.3.z
            )
            let anchorPos = routeNode.simdWorldPosition
            let distance = simd_distance(cameraPos, anchorPos)
            let tracking = frame.camera.trackingState
            let routeScale =
                routeNode.childNodes.first?.simdScale.x ?? 0

            print(
                """
                [AR-DIAG] camera=\(cameraPos) \
                anchor=\(anchorPos) \
                dist=\(String(format: "%.3f", distance))m \
                scale=\(String(format: "%.3f", routeScale)) \
                tracking=\(tracking) \
                nodes=\(scnView.scene.rootNode.childNodes.count)
                """
            )
        }
    #endif
}

// swiftlint:enable type_body_length
