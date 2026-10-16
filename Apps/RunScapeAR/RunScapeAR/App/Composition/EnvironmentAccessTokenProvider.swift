//
//  EnvironmentAccessTokenProvider.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import DataLayer
import Foundation

struct EnvironmentAccessTokenProvider: AccessTokenProvider {
    func accessToken() async throws -> String {
        guard
            let token = ProcessInfo.processInfo.environment[
                "STRAVA_ACCESS_TOKEN"
            ],
            !token.isEmpty
        else {
            throw EnvironmentAccessTokenError.missingAccessToken
        }

        return token
    }
}

enum EnvironmentAccessTokenError: Error {
    case missingAccessToken
}
