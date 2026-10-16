//
//  StravaActivityStreamMappingError.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

enum StravaActivityStreamMappingError: Error, Equatable {
    case missingCoordinates
    case missingDistance
    case missingAltitude
    case inconsistentStreamSizes
}
