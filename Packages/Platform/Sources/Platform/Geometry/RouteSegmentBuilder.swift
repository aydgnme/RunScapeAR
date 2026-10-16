//
//  RouteSegmentBuilder.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

public struct RouteSegmentBuilder: Sendable {
    public init() {}

    public func build(
        from points: [LocalPoint3D]
    ) -> [RouteSegment] {
        guard points.count >= 2 else {
            return []
        }

        return zip(
            points,
            points.dropFirst()
        ).map { start, end in
            RouteSegment(
                start: start,
                end: end
            )
        }
    }
}
