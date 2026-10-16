//
//  LocalPoint3D.swift
//  Platform
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

public struct LocalPoint3D: Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}
