//
//  HTTPClient.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

public protocol HTTPClient: Sendable {
    func send(
        _ request: HTTPRequest
    ) async throws -> HTTPResponse
}
