//
//  NetworkError.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

public enum NetworkError: Error, Equatable, Sendable {
    case invalidResponse
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case unexpectedStatusCode(Int)
}
