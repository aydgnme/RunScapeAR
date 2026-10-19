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
            ContentUnavailableView {
                Label(
                    "Couldn't Load Route",
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
        } else if let route = viewModel.route {
            routeContent(route)
        } else {
            ContentUnavailableView(
                "Route Unavailable",
                systemImage: "map"
            )
        }
    }

    private func routeContent(
        _ route: Route
    ) -> some View {
        RoutePreviewView(
            points: route.points
        )
        .safeAreaInset(
            edge: .bottom
        ) {
            VStack(spacing: 0) {
                if let stats = viewModel.statistics {
                    statisticsBar(
                        route: route,
                        stats: stats
                    )
                }

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
            }
            .background(
                .ultraThinMaterial
            )
        }
    }

    private func statisticsBar(
        route: Route,
        stats: RouteStatistics
    ) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                statItem(
                    icon: "figure.run",
                    label: "Distance",
                    value: formatDistance(route.distance)
                )

                Divider().frame(height: 32)

                statItem(
                    icon: "arrow.up.right",
                    label: "Ascent",
                    value: formatElevation(stats.elevationGain)
                )

                Divider().frame(height: 32)

                statItem(
                    icon: "arrow.down.right",
                    label: "Descent",
                    value: formatElevation(stats.elevationLoss)
                )

                Divider().frame(height: 32)

                statItem(
                    icon: "mountain.2",
                    label: "Altitude",
                    value: formatAltitudeRange(
                        min: stats.minimumAltitude,
                        max: stats.maximumAltitude
                    )
                )

                if stats.maximumGradient > 0 {
                    Divider().frame(height: 32)

                    statItem(
                        icon: "arrow.up.forward",
                        label: "Max Grade",
                        value: formatGradient(stats.maximumGradient)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    private func statItem(
        icon: String,
        label: String,
        value: String
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func formatDistance(
        _ metres: Double
    ) -> String {
        String(
            format: "%.1f km",
            metres / 1000
        )
    }

    private func formatElevation(
        _ metres: Double
    ) -> String {
        String(
            format: "%.0f m",
            metres
        )
    }

    private func formatAltitudeRange(
        min: Double,
        max: Double
    ) -> String {
        String(
            format: "%.0f–%.0f m",
            min,
            max
        )
    }

    private func formatGradient(
        _ percent: Double
    ) -> String {
        String(
            format: "%.1f%%",
            percent
        )
    }
}
