//
//  StravaClientTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Foundation
import Testing

private struct StaticAccessTokenProvider: AccessTokenProvider {
    let token: String

    func accessToken() async throws -> String {
        token
    }
}

private actor MockHTTPClient: HTTPClient {
    private let response: HTTPResponse
    private var lastRequest: HTTPRequest?

    init(response: HTTPResponse) {
        self.response = response
    }

    func send(
        _ request: HTTPRequest
    ) async throws -> HTTPResponse {
        lastRequest = request
        return response
    }

    func capturedRequest() -> HTTPRequest? {
        lastRequest
    }
}

@Test
func authenticatedAthleteRequestIsBuiltCorrectly() async throws {
    let httpClient = MockHTTPClient(
        response: HTTPResponse(
            data: Data(),
            statusCode: 200
        )
    )

    let tokenProvider = StaticAccessTokenProvider(
        token: "test-token"
    )

    let client = StravaClient(
        httpClient: httpClient,
        tokenProvider: tokenProvider
    )

    _ = try await client.get(
        .authenticatedAthlete
    )

    let request = await httpClient.capturedRequest()

    #expect(
        request?.url.absoluteString ==
            "https://www.strava.com/api/v3/athlete"
    )

    #expect(request?.method == .get)

    #expect(
        request?.headers["Authorization"] ==
            "Bearer test-token"
    )

    #expect(
        request?.headers["Accept"] ==
            "application/json"
    )

    #expect(request?.body == nil)
}

@Test
func unauthorizedResponseThrowsUnauthorizedError() async {
    let httpClient = MockHTTPClient(
        response: HTTPResponse(
            data: Data(),
            statusCode: 401
        )
    )

    let client = StravaClient(
        httpClient: httpClient,
        tokenProvider: StaticAccessTokenProvider(
            token: "test-token"
        )
    )

    do {
        _ = try await client.get(
            .authenticatedAthlete
        )

        Issue.record(
            "Expected unauthorized error"
        )
    } catch let error as StravaError {
        #expect(error == .unauthorized)
    } catch {
        Issue.record(
            "Unexpected error: \(error)"
        )
    }
}

@Test
func rateLimitedResponseThrowsRateLimitedError() async {
    let httpClient = MockHTTPClient(
        response: HTTPResponse(
            data: Data(),
            statusCode: 429
        )
    )

    let client = StravaClient(
        httpClient: httpClient,
        tokenProvider: StaticAccessTokenProvider(
            token: "test-token"
        )
    )

    do {
        _ = try await client.get(
            .authenticatedAthlete
        )

        Issue.record(
            "Expected rate limited error"
        )
    } catch let error as StravaError {
        #expect(error == .rateLimited)
    } catch {
        Issue.record(
            "Unexpected error: \(error)"
        )
    }
}

@Test
func serverErrorPreservesStatusCode() async {
    let httpClient = MockHTTPClient(
        response: HTTPResponse(
            data: Data(),
            statusCode: 503
        )
    )

    let client = StravaClient(
        httpClient: httpClient,
        tokenProvider: StaticAccessTokenProvider(
            token: "test-token"
        )
    )

    do {
        _ = try await client.get(
            .authenticatedAthlete
        )

        Issue.record(
            "Expected server error"
        )
    } catch let error as StravaError {
        #expect(error == .serverError(503))
    } catch {
        Issue.record(
            "Unexpected error: \(error)"
        )
    }
}
