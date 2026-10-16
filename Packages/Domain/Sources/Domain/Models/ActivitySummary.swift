//
//  ActivitySummary.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct ActivitySummary: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let distance: Double
    public let movingTime: TimeInterval
    public let elapsedTime: TimeInterval
    public let elevationGain: Double
    public let sportType: String

    public init(
        id: String,
        name: String,
        distance: Double,
        movingTime: TimeInterval,
        elapsedTime: TimeInterval,
        elevationGain: Double,
        sportType: String
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.movingTime = movingTime
        self.elapsedTime = elapsedTime
        self.elevationGain = elevationGain
        self.sportType = sportType
    }
}
