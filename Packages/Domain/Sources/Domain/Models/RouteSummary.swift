//
//  RouteSummary.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

public struct RouteSummary: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let distance: Double
    public let elevationGain: Double

    public init(
        id: String,
        name: String,
        distance: Double,
        elevationGain: Double
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.elevationGain = elevationGain
    }
}
