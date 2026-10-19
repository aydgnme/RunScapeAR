import Domain
import SwiftUI

struct RoutesView: View {
    @State private var viewModel: RoutesViewModel

    private let makeRouteDetailViewModel:
        @MainActor (String) -> RouteDetailViewModel

    var showSignOut = false
    var onSignOut: (() -> Void)?

    init(
        viewModel: RoutesViewModel,
        makeRouteDetailViewModel:
        @escaping @MainActor (String) -> RouteDetailViewModel,
        showSignOut: Bool = false,
        onSignOut: (() -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: viewModel
        )

        self.makeRouteDetailViewModel = makeRouteDetailViewModel
        self.showSignOut = showSignOut
        self.onSignOut = onSignOut
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Routes")
                .toolbar {
                    if showSignOut {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out") {
                                onSignOut?()
                            }
                        }
                    }
                }
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
            ContentUnavailableView {
                Label(
                    "Couldn't Load Routes",
                    systemImage: "exclamationmark.triangle"
                )
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Try Again") {
                    Task {
                        await viewModel.retry()
                    }
                }
            }
        } else if viewModel.routes.isEmpty {
            ContentUnavailableView(
                "No Routes",
                systemImage: "map",
                description: Text(
                    "No routes found in your Strava account."
                )
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
