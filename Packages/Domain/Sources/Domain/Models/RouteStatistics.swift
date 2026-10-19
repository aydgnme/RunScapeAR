import Foundation

public struct RouteStatistics: Equatable, Sendable {
    public let totalDistance: Double
    public let elevationGain: Double
    public let elevationLoss: Double
    public let minimumAltitude: Double
    public let maximumAltitude: Double
    public let maximumGradient: Double
    public let steepestDescent: Double

    public init(
        totalDistance: Double,
        elevationGain: Double,
        elevationLoss: Double,
        minimumAltitude: Double,
        maximumAltitude: Double,
        maximumGradient: Double,
        steepestDescent: Double
    ) {
        self.totalDistance = totalDistance
        self.elevationGain = elevationGain
        self.elevationLoss = elevationLoss
        self.minimumAltitude = minimumAltitude
        self.maximumAltitude = maximumAltitude
        self.maximumGradient = maximumGradient
        self.steepestDescent = steepestDescent
    }
}
