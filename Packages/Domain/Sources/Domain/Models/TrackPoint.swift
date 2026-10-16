//
//  TrackPoint.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public struct TrackPoint: Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let altitude: Double
    public let distance: Double

    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double,
        distance: Double
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.distance = distance
    }
}
