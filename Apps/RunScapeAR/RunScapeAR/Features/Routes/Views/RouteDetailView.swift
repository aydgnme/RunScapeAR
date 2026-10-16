//
//  RouteDetailView.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import SwiftUI

struct RouteDetailView: View {
    @State private var viewModel: RouteDetailViewModel

    init(
        viewModel: RouteDetailViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {
        content
            .navigationTitle(
                viewModel.route?.name ?? "Route"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading,
           viewModel.route == nil
        {
            ProgressView(
                "Loading route..."
            )
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Couldn’t Load Route",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else if let route = viewModel.route {
            RoutePreviewView(
                points: route.points
            )
            .safeAreaInset(
                edge: .bottom
            ) {
                NavigationLink {
                    ARRouteView(
                        points: route.points
                    )
                    .navigationTitle("AR Route")
                    .navigationBarTitleDisplayMode(
                        .inline
                    )
                } label: {
                    Label(
                        "View in AR",
                        systemImage: "arkit"
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    .borderedProminent
                )
                .controlSize(
                    .large
                )
                .padding()
                .background(
                    .ultraThinMaterial
                )
            }
        } else {
            ContentUnavailableView(
                "Route Unavailable",
                systemImage: "map"
            )
        }
    }
}
