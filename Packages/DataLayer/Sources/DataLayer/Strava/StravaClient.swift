//
//  StravaClient.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public final class StravaClient: @unchecked Sendable {
    private let httpClient: any HTTPClient
    private let tokenProvider: any AccessTokenProvider

    private let baseURL = URL(
        string: "https://www.strava.com/api/v3"
    )!

    public init(
        httpClient: any HTTPClient,
        tokenProvider: any AccessTokenProvider
    ) {
        self.httpClient = httpClient
        self.tokenProvider = tokenProvider
    }

    func get(
        _ endpoint: StravaEndpoint
    ) async throws -> HTTPResponse {
        let token = try await tokenProvider.accessToken()

        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw StravaError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw StravaError.invalidURL
        }

        let request = HTTPRequest(
            url: url,
            method: .get,
            headers: [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
        )

        let response = try await httpClient.send(request)

        try validate(response)

        return response
    }

    func get<T: Decodable & Sendable>(
        _ endpoint: StravaEndpoint,
        as type: T.Type
    ) async throws -> T {
        let response = try await get(endpoint)

        do {
            return try JSONDecoder().decode(
                T.self,
                from: response.data
            )
        } catch {
            throw StravaError.decodingFailed
        }
    }

    private func validate(
        _ response: HTTPResponse
    ) throws {
        switch response.statusCode {
        case 200 ..< 300:
            return

        case 401:
            throw StravaError.unauthorized

        case 403:
            throw StravaError.forbidden

        case 404:
            throw StravaError.notFound

        case 429:
            throw StravaError.rateLimited

        case 500 ..< 600:
            throw StravaError.serverError(
                response.statusCode
            )

        default:
            throw StravaError.unexpectedStatusCode(
                response.statusCode
            )
        }
    }
}
