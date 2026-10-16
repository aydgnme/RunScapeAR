//
//  RouteSegment.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

public struct RouteSegment: Equatable, Sendable {
    public let start: LocalPoint3D
    public let end: LocalPoint3D

    public init(
        start: LocalPoint3D,
        end: LocalPoint3D
    ) {
        self.start = start
        self.end = end
    }

    public var midpoint: LocalPoint3D {
        LocalPoint3D(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2,
            z: (start.z + end.z) / 2
        )
    }

    public var length: Double {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let deltaZ = end.z - start.z

        return (
            deltaX * deltaX
                + deltaY * deltaY
                + deltaZ * deltaZ
        ).squareRoot()
    }
}
