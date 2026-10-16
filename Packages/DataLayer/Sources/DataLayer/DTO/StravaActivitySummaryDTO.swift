//
//  StravaActivitySummaryDTO.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

struct StravaActivitySummaryDTO: Decodable, Sendable {
    let id: Int64
    let name: String
    let distance: Double
    let movingTime: Int
    let elapsedTime: Int
    let totalElevationGain: Double
    let sportType: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case distance
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case totalElevationGain = "total_elevation_gain"
        case sportType = "sport_type"
    }
}
