//
//  StravaActivityDTO.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

struct StravaActivityDTO: Decodable, Sendable {
    let id: Int64
    let name: String
    let distance: Double
    let movingTime: Int
    let elapsedTime: Int
    let totalElevationGain: Double
    let sportType: String

    let averageSpeed: Double?
    let maxSpeed: Double?
    let averageHeartRate: Double?
    let maxHeartRate: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case distance
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case totalElevationGain = "total_elevation_gain"
        case sportType = "sport_type"

        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case averageHeartRate = "average_heartrate"
        case maxHeartRate = "max_heartrate"
    }

    init(
        id: Int64,
        name: String,
        distance: Double,
        movingTime: Int,
        elapsedTime: Int,
        totalElevationGain: Double,
        sportType: String,
        averageSpeed: Double? = nil,
        maxSpeed: Double? = nil,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.movingTime = movingTime
        self.elapsedTime = elapsedTime
        self.totalElevationGain = totalElevationGain
        self.sportType = sportType
        self.averageSpeed = averageSpeed
        self.maxSpeed = maxSpeed
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
    }
}
