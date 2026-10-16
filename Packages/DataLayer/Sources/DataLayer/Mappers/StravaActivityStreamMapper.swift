//
//  StravaActivityStreamMapper.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Domain

struct StravaActivityStreamMapper: Sendable {
    func map(
        _ streams: [StravaStreamDTO]
    ) throws -> [ActivityPoint] {
        let required = try requiredStreams(
            from: streams
        )

        let optional = optionalStreams(
            from: streams
        )

        try validateStreamSizes(
            count: required.coordinates.count,
            distances: required.distances,
            altitudes: required.altitudes,
            optional: optional
        )

        return makePoints(
            coordinates: required.coordinates,
            distances: required.distances,
            altitudes: required.altitudes,
            optional: optional
        )
    }

    private struct RequiredStreams {
        let coordinates: [StravaStreamDTO.Coordinate]
        let distances: [Double]
        let altitudes: [Double]
    }

    private struct OptionalStreams {
        let times: [Double]?
        let speeds: [Double]?
        let heartRates: [Double]?
        let cadences: [Double]?
        let grades: [Double]?
    }

    private func requiredStreams(
        from streams: [StravaStreamDTO]
    ) throws -> RequiredStreams {
        guard
            let coordinateStream = streams.first(
                where: { $0.type == "latlng" }
            ),
            case let .coordinates(coordinates) = coordinateStream.data
        else {
            throw StravaActivityStreamMappingError.missingCoordinates
        }

        guard let distances = values(
            for: "distance",
            in: streams
        ) else {
            throw StravaActivityStreamMappingError.missingDistance
        }

        guard let altitudes = values(
            for: "altitude",
            in: streams
        ) else {
            throw StravaActivityStreamMappingError.missingAltitude
        }

        return RequiredStreams(
            coordinates: coordinates,
            distances: distances,
            altitudes: altitudes
        )
    }

    private func optionalStreams(
        from streams: [StravaStreamDTO]
    ) -> OptionalStreams {
        OptionalStreams(
            times: values(for: "time", in: streams),
            speeds: values(for: "velocity_smooth", in: streams),
            heartRates: values(for: "heartrate", in: streams),
            cadences: values(for: "cadence", in: streams),
            grades: values(for: "grade_smooth", in: streams)
        )
    }

    private func validateStreamSizes(
        count: Int,
        distances: [Double],
        altitudes: [Double],
        optional: OptionalStreams
    ) throws {
        guard
            distances.count == count,
            altitudes.count == count
        else {
            throw StravaActivityStreamMappingError.inconsistentStreamSizes
        }

        let optionalValues = [
            optional.times,
            optional.speeds,
            optional.heartRates,
            optional.cadences,
            optional.grades
        ].compactMap(\.self)

        guard optionalValues.allSatisfy({
            $0.count == count
        }) else {
            throw StravaActivityStreamMappingError.inconsistentStreamSizes
        }
    }

    private func makePoints(
        coordinates: [StravaStreamDTO.Coordinate],
        distances: [Double],
        altitudes: [Double],
        optional: OptionalStreams
    ) -> [ActivityPoint] {
        coordinates.indices.map { index in
            ActivityPoint(
                trackPoint: TrackPoint(
                    latitude: coordinates[index].latitude,
                    longitude: coordinates[index].longitude,
                    altitude: altitudes[index],
                    distance: distances[index]
                ),
                time: optional.times?[index],
                speed: optional.speeds?[index],
                heartRate: optional.heartRates?[index],
                cadence: optional.cadences?[index],
                grade: optional.grades?[index]
            )
        }
    }

    private func values(
        for type: String,
        in streams: [StravaStreamDTO]
    ) -> [Double]? {
        guard
            let stream = streams.first(
                where: { $0.type == type }
            ),
            case let .values(values) = stream.data
        else {
            return nil
        }

        return values
    }
}
