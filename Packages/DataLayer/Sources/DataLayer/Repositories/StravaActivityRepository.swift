//
//  StravaActivityRepository.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

import Domain

public final class StravaActivityRepository:
    ActivityRepository,
    @unchecked Sendable
{
    private let api: any StravaAPI

    private let activityMapper: StravaActivityMapper
    private let streamMapper: StravaActivityStreamMapper

    public convenience init(
        client: StravaClient
    ) {
        self.init(
            api: client,
            activityMapper: StravaActivityMapper(),
            streamMapper: StravaActivityStreamMapper()
        )
    }

    init(
        api: any StravaAPI,
        activityMapper: StravaActivityMapper = StravaActivityMapper(),
        streamMapper: StravaActivityStreamMapper = StravaActivityStreamMapper()
    ) {
        self.api = api
        self.activityMapper = activityMapper
        self.streamMapper = streamMapper
    }

    public func fetchActivities() async throws -> [ActivitySummary] {
        let activities = try await api.activities(
            page: 1,
            perPage: 30
        )

        return activities.map {
            activityMapper.summary(from: $0)
        }
    }

    public func fetchActivity(
        id: String
    ) async throws -> Activity {
        guard let activityID = Int64(id) else {
            throw StravaRepositoryError.invalidActivityID
        }

        async let activityRequest = api.activity(
            id: activityID
        )

        async let streamsRequest = api.activityStreams(
            id: activityID
        )

        let (activityDTO, streams) = try await (
            activityRequest,
            streamsRequest
        )

        let points = try streamMapper.map(
            streams
        )

        return activityMapper.activity(
            from: activityDTO,
            points: points
        )
    }
}
