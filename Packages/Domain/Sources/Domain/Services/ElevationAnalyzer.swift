import Foundation

public struct ElevationAnalyzer: Sendable {
    private let minimumSegmentDistance: Double
    private let gradientCap: Double

    public init(
        minimumSegmentDistance: Double = 1.0,
        gradientCap: Double = 100.0
    ) {
        self.minimumSegmentDistance = minimumSegmentDistance
        self.gradientCap = gradientCap
    }

    public func analyze(
        points: [TrackPoint]
    ) -> RouteStatistics? {
        guard points.count >= 2 else {
            return nil
        }

        var elevationGain = 0.0
        var elevationLoss = 0.0
        var minimumAltitude = points[0].altitude
        var maximumAltitude = points[0].altitude
        var maximumGradient = 0.0
        var steepestDescent = 0.0

        for index in 1 ..< points.count {
            let current = points[index]
            let previous = points[index - 1]

            minimumAltitude = min(minimumAltitude, current.altitude)
            maximumAltitude = max(maximumAltitude, current.altitude)

            let elevationDelta = current.altitude - previous.altitude
            let distanceDelta = current.distance - previous.distance

            if elevationDelta > 0 {
                elevationGain += elevationDelta
            } else {
                elevationLoss += abs(elevationDelta)
            }

            guard distanceDelta >= minimumSegmentDistance else {
                continue
            }

            let gradient = (elevationDelta / distanceDelta) * 100.0
            let clamped = min(max(gradient, -gradientCap), gradientCap)

            if clamped > maximumGradient {
                maximumGradient = clamped
            }

            if clamped < steepestDescent {
                steepestDescent = clamped
            }
        }

        let totalDistance = points.last!.distance - points.first!.distance

        return RouteStatistics(
            totalDistance: totalDistance,
            elevationGain: elevationGain,
            elevationLoss: elevationLoss,
            minimumAltitude: minimumAltitude,
            maximumAltitude: maximumAltitude,
            maximumGradient: maximumGradient,
            steepestDescent: steepestDescent
        )
    }
}
