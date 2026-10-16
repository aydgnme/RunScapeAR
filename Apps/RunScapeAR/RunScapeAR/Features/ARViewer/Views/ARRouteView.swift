//
//  ARRouteView.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import SwiftUI

struct ARRouteView: View {
    let points: [TrackPoint]

    @State private var instruction =
        "Point at a flat surface and tap"

    var body: some View {
        ZStack(alignment: .top) {
            ARRouteCameraView(
                points: points,
                instruction: $instruction
            )
            .ignoresSafeArea()

            Text(instruction)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    .ultraThinMaterial,
                    in: Capsule()
                )
                .padding(.top, 16)
        }
    }
}
