//
//  AccessTokenProvider.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

public protocol AccessTokenProvider: Sendable {
    func accessToken() async throws -> String
}
