//
//  RouteNormalizer.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

public struct RouteNormalizer: Sendable {
    public let targetHorizontalSize: Double
    public let elevationExaggeration: Double

    public init(
        targetHorizontalSize: Double = 0.7,
        elevationExaggeration: Double = 3.0
    ) {
        self.targetHorizontalSize = targetHorizontalSize
        self.elevationExaggeration = elevationExaggeration
    }

    public func normalize(
        _ points: [LocalPoint3D]
    ) -> [LocalPoint3D] {
        guard !points.isEmpty else {
            return []
        }

        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 0

        let minY = points.map(\.y).min() ?? 0

        let minZ = points.map(\.z).min() ?? 0
        let maxZ = points.map(\.z).max() ?? 0

        let width = maxX - minX
        let depth = maxZ - minZ

        let largestHorizontalDimension = max(
            width,
            depth
        )

        let scale = largestHorizontalDimension > 0
            ? targetHorizontalSize / largestHorizontalDimension
            : 1.0

        let centerX = (minX + maxX) / 2.0
        let centerZ = (minZ + maxZ) / 2.0

        return points.map { point in
            LocalPoint3D(
                x: (point.x - centerX) * scale,
                y: (point.y - minY)
                    * scale
                    * elevationExaggeration,
                z: (point.z - centerZ) * scale
            )
        }
    }
}
