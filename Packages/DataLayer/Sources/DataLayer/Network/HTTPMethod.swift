//
//  HTTPMethod.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

public enum HTTPMethod: String, Equatable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
