//
//  URLSessionHTTPClient.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient, @unchecked Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(
        _ request: HTTPRequest
    ) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)

        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let headers = httpResponse.allHeaderFields.reduce(
            into: [String: String]()
        ) { result, item in
            guard
                let key = item.key as? String,
                let value = item.value as? String
            else {
                return
            }

            result[key] = value
        }

        return HTTPResponse(
            data: data,
            statusCode: httpResponse.statusCode,
            headers: headers
        )
    }
}
