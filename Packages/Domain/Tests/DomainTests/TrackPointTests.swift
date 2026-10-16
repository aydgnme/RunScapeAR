//
//  TrackPointTests.swift
//  Domain
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import Domain
import Testing

@Test
func trackPointStoresValues() {
    let point = TrackPoint(
        latitude: 47.651,
        longitude: 26.255,
        altitude: 352.4,
        distance: 124.8
    )

    #expect(point.latitude == 47.651)
    #expect(point.longitude == 26.255)
    #expect(point.altitude == 352.4)
    #expect(point.distance == 124.8)
}
