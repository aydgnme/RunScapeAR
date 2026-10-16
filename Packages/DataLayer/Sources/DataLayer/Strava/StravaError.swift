//
//  StravaError.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

public enum StravaError: Error, Equatable, Sendable {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case decodingFailed
}
