//
//  StravaRouteDTO.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

struct StravaRouteDTO: Decodable, Sendable {
    let id: Int64
    let name: String
    let distance: Double
    let elevationGain: Double
    let estimatedMovingTime: Int?
    let description: String?

    init(
        id: Int64,
        name: String,
        distance: Double,
        elevationGain: Double,
        estimatedMovingTime: Int? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.elevationGain = elevationGain
        self.estimatedMovingTime = estimatedMovingTime
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case distance
        case elevationGain = "elevation_gain"
        case estimatedMovingTime = "estimated_moving_time"
        case description
    }
}
