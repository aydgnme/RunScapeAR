import Domain
import SwiftUI

struct ARRouteView: View {
    let points: [TrackPoint]

    @Environment(\.scenePhase) private var scenePhase
    @State private var instruction =
        "Point at a flat surface"
    @State private var isPlaced = false
    @State private var surfaceReady = false
    @State private var resetRequestID = 0
    @State private var isActive = true

    var body: some View {
        ZStack {
            arContent
        }
        .onChange(of: scenePhase) { _, newPhase in
            isActive = newPhase == .active
        }
    }

    private var arContent: some View {
        ZStack {
            ARRouteCameraView(
                points: points,
                resetRequestID: resetRequestID,
                isActive: isActive,
                instruction: $instruction,
                isPlaced: $isPlaced,
                surfaceReady: $surfaceReady
            )
            .ignoresSafeArea()

            if !isPlaced {
                Circle()
                    .stroke(
                        surfaceReady ? Color.green : Color.white,
                        lineWidth: 2
                    )
                    .frame(width: 24, height: 24)
                    .opacity(0.8)
            }

            VStack {
                Text(instruction)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        .ultraThinMaterial,
                        in: Capsule()
                    )

                if isPlaced {
                    Button {
                        resetRequestID += 1
                    } label: {
                        Label(
                            "Reposition Route",
                            systemImage: "arrow.counterclockwise"
                        )
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            .ultraThinMaterial,
                            in: Capsule()
                        )
                    }
                }

                Spacer()
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    ARRouteView(
        points: PreviewData.trackPoints
    )
}
