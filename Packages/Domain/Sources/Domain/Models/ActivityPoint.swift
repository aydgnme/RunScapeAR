//
//  ActivityPoint.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct ActivityPoint: Equatable, Sendable {
    public let trackPoint: TrackPoint

    public let time: TimeInterval?
    public let speed: Double?
    public let heartRate: Double?
    public let cadence: Double?
    public let grade: Double?

    public init(
        trackPoint: TrackPoint,
        time: TimeInterval?,
        speed: Double?,
        heartRate: Double?,
        cadence: Double?,
        grade: Double?
    ) {
        self.trackPoint = trackPoint
        self.time = time
        self.speed = speed
        self.heartRate = heartRate
        self.cadence = cadence
        self.grade = grade
    }
}
