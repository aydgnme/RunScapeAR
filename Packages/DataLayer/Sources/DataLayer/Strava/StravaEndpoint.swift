//
//  StravaEndpoint.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

enum StravaEndpoint {
    case authenticatedAthlete

    case athleteRoutes(
        athleteID: Int64,
        page: Int,
        perPage: Int
    )

    case route(id: Int64)

    case routeStreams(id: Int64)

    case athleteActivities(
        page: Int,
        perPage: Int
    )

    case activity(id: Int64)

    case activityStreams(
        id: Int64,
        keys: [String]
    )

    var path: String {
        switch self {
        case .authenticatedAthlete:
            "/athlete"

        case let .athleteRoutes(athleteID, _, _):
            "/athletes/\(athleteID)/routes"

        case let .route(id):
            "/routes/\(id)"

        case let .routeStreams(id):
            "/routes/\(id)/streams"

        case .athleteActivities:
            "/athlete/activities"

        case let .activity(id):
            "/activities/\(id)"

        case let .activityStreams(id, _):
            "/activities/\(id)/streams"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .athleteRoutes(_, page, perPage):
            [
                URLQueryItem(
                    name: "page",
                    value: String(page)
                ),
                URLQueryItem(
                    name: "per_page",
                    value: String(perPage)
                )
            ]

        case let .athleteActivities(page, perPage):
            [
                URLQueryItem(
                    name: "page",
                    value: String(page)
                ),
                URLQueryItem(
                    name: "per_page",
                    value: String(perPage)
                )
            ]

        case let .activityStreams(_, keys):
            [
                URLQueryItem(name: "keys", value: keys.joined(separator: ",")),
                URLQueryItem(name: "key_by_type", value: "true")
            ]

        default:
            []
        }
    }
}
