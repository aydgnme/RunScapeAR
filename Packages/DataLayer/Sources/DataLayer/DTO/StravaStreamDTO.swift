//
//  StravaStreamDTO.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

struct StravaStreamDTO: Decodable, Sendable {
    let type: String
    let data: StreamData
    let seriesType: String?
    let originalSize: Int?
    let resolution: String?

    enum CodingKeys: String, CodingKey {
        case type
        case data
        case seriesType = "series_type"
        case originalSize = "original_size"
        case resolution
    }

    enum StreamData: Sendable {
        case values([Double])
        case coordinates([Coordinate])
        case unsupported
    }

    struct Coordinate: Sendable, Equatable {
        let latitude: Double
        let longitude: Double
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        type = try Self.decodeType(
            from: container,
            decoder: decoder
        )

        seriesType = try container.decodeIfPresent(
            String.self,
            forKey: .seriesType
        )

        originalSize = try container.decodeIfPresent(
            Int.self,
            forKey: .originalSize
        )

        resolution = try container.decodeIfPresent(
            String.self,
            forKey: .resolution
        )

        data = try Self.decodeData(
            type: type,
            from: container
        )
    }

    private static func decodeType(
        from container: KeyedDecodingContainer<CodingKeys>,
        decoder: Decoder
    ) throws -> String {
        try container.decodeIfPresent(
            String.self,
            forKey: .type
        )
            ?? decoder.codingPath.last?.stringValue
            ?? "unknown"
    }

    private static func decodeData(
        type: String,
        from container: KeyedDecodingContainer<CodingKeys>
    ) throws -> StreamData {
        switch type {
        case "latlng":
            try decodeCoordinates(
                from: container
            )

        case "time",
             "distance",
             "altitude",
             "velocity_smooth",
             "heartrate",
             "cadence",
             "grade_smooth":
            try decodeValues(
                from: container
            )

        default:
            .unsupported
        }
    }

    private static func decodeCoordinates(
        from container: KeyedDecodingContainer<CodingKeys>
    ) throws -> StreamData {
        let rawCoordinates = try container.decode(
            [[Double]].self,
            forKey: .data
        )

        let coordinates: [Coordinate] = rawCoordinates.compactMap { pair -> Coordinate? in
            guard pair.count == 2 else {
                return nil
            }

            return Coordinate(
                latitude: pair[0],
                longitude: pair[1]
            )
        }

        return .coordinates(coordinates)
    }

    private static func decodeValues(
        from container: KeyedDecodingContainer<CodingKeys>
    ) throws -> StreamData {
        if let values = try? container.decode(
            [Double].self,
            forKey: .data
        ) {
            return .values(values)
        }

        let integerValues = try container.decode(
            [Int].self,
            forKey: .data
        )

        return .values(
            integerValues.map(Double.init)
        )
    }
}
