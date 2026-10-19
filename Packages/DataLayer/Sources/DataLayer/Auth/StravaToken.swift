import Foundation

public struct StravaToken: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date
    public let athleteID: Int64

    public init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date,
        athleteID: Int64
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.athleteID = athleteID
    }

    public var isExpired: Bool {
        Date() >= expiresAt
    }
}
