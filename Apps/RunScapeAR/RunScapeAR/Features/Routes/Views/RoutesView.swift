//
//  RoutesView.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import SwiftUI

struct RoutesView: View {
    @State private var viewModel: RoutesViewModel

    private let makeRouteDetailViewModel:
        @MainActor (String) -> RouteDetailViewModel

    init(
        viewModel: RoutesViewModel,
        makeRouteDetailViewModel:
        @escaping @MainActor (String) -> RouteDetailViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )

        self.makeRouteDetailViewModel = makeRouteDetailViewModel
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Routes")
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading,
           viewModel.routes.isEmpty
        {
            ProgressView(
                "Loading Strava routes..."
            )
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Couldn’t Load Routes",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else {
            List(
                viewModel.routes
            ) { route in
                NavigationLink {
                    RouteDetailView(
                        viewModel: makeRouteDetailViewModel(
                            route.id
                        )
                    )
                } label: {
                    routeRow(route)
                }
            }
        }
    }

    private func routeRow(
        _ route: RouteSummary
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            Text(route.name)
                .font(.headline)

            HStack {
                Label(
                    distanceText(route.distance),
                    systemImage: "figure.run"
                )

                Spacer()

                Label(
                    elevationText(route.elevationGain),
                    systemImage: "mountain.2"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(
            .vertical,
            4
        )
    }

    private func distanceText(
        _ metres: Double
    ) -> String {
        String(
            format: "%.2f km",
            metres / 1000
        )
    }

    private func elevationText(
        _ metres: Double
    ) -> String {
        String(
            format: "+%.0f m",
            metres
        )
    }
}
