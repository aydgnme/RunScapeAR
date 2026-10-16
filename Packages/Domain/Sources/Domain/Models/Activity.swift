//
//  Activity.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct Activity: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String

    public let distance: Double
    public let movingTime: TimeInterval
    public let elapsedTime: TimeInterval

    public let elevationGain: Double

    public let averageSpeed: Double?
    public let maximumSpeed: Double?

    public let averageHeartRate: Double?
    public let maximumHeartRate: Double?

    public let points: [ActivityPoint]

    public init(
        id: String,
        name: String,
        distance: Double,
        movingTime: TimeInterval,
        elapsedTime: TimeInterval,
        elevationGain: Double,
        averageSpeed: Double?,
        maximumSpeed: Double?,
        averageHeartRate: Double?,
        maximumHeartRate: Double?,
        points: [ActivityPoint]
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.movingTime = movingTime
        self.elapsedTime = elapsedTime
        self.elevationGain = elevationGain
        self.averageSpeed = averageSpeed
        self.maximumSpeed = maximumSpeed
        self.averageHeartRate = averageHeartRate
        self.maximumHeartRate = maximumHeartRate
        self.points = points
    }
}
