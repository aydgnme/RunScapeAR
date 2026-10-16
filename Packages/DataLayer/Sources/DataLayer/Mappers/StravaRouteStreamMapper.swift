//
//  StravaRouteStreamMapper.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Domain

struct StravaRouteStreamMapper {
    func map(
        _ streams: [StravaStreamDTO]
    ) throws -> [TrackPoint] {
        guard
            let coordinatesStream = streams.first(
                where: { $0.type == "latlng" }
            ),
            case let .coordinates(coordinates) = coordinatesStream.data
        else {
            throw StravaStreamMappingError.missingCoordinates
        }

        guard
            let distanceStream = streams.first(
                where: { $0.type == "distance" }
            ),
            case let .values(distances) = distanceStream.data
        else {
            throw StravaStreamMappingError.missingDistance
        }

        guard
            let altitudeStream = streams.first(
                where: { $0.type == "altitude" }
            ),
            case let .values(altitudes) = altitudeStream.data
        else {
            throw StravaStreamMappingError.missingAltitude
        }

        guard
            coordinates.count == distances.count,
            coordinates.count == altitudes.count
        else {
            throw StravaStreamMappingError.inconsistentStreamSizes
        }

        return coordinates.indices.map { index in
            TrackPoint(
                latitude: coordinates[index].latitude,
                longitude: coordinates[index].longitude,
                altitude: altitudes[index],
                distance: distances[index]
            )
        }
    }
}
