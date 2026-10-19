import Domain
import SwiftUI

struct ARRouteView: View {
    let points: [TrackPoint]

    @State private var instruction =
        "Point at a flat surface and tap"
    @State private var isPlaced = false

    var body: some View {
        ZStack(alignment: .top) {
            ARRouteCameraView(
                points: points,
                instruction: $instruction,
                isPlaced: $isPlaced
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
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
                        isPlaced = false
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
