//
//  TrackPointProjector.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import Foundation

public struct TrackPointProjector: Sendable {
    private let earthRadius = 6_371_000.0

    public init() {}

    public func project(
        _ points: [TrackPoint]
    ) -> [LocalPoint3D] {
        guard let origin = points.first else {
            return []
        }

        let originLatitude = degreesToRadians(
            origin.latitude
        )

        let originLongitude = degreesToRadians(
            origin.longitude
        )

        return points.map { point in
            let latitude = degreesToRadians(
                point.latitude
            )

            let longitude = degreesToRadians(
                point.longitude
            )

            let deltaLatitude =
                latitude - originLatitude

            let deltaLongitude =
                longitude - originLongitude

            let averageLatitude =
                (latitude + originLatitude) / 2.0

            let east =
                earthRadius
                    * deltaLongitude
                    * cos(averageLatitude)

            let north =
                earthRadius
                    * deltaLatitude

            let elevation =
                point.altitude - origin.altitude

            return LocalPoint3D(
                x: east,
                y: elevation,
                z: -north
            )
        }
    }

    private func degreesToRadians(
        _ degrees: Double
    ) -> Double {
        degrees * .pi / 180.0
    }
}
