//
//  StravaRouteStreamMapperTests.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

@testable import DataLayer
import Foundation
import Testing

@Test
func routeStreamsAreMappedToTrackPoints() throws {
    let json = """
    [
        {
            "type": "latlng",
            "data": [
                [47.4400, 25.5600],
                [47.4410, 25.5610]
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        {
            "type": "distance",
            "data": [
                0.0,
                150.0
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        },
        {
            "type": "altitude",
            "data": [
                792.0,
                814.0
            ],
            "series_type": "distance",
            "original_size": 2,
            "resolution": "high"
        }
    ]
    """

    let streams = try JSONDecoder().decode(
        [StravaStreamDTO].self,
        from: Data(json.utf8)
    )

    let points = try StravaRouteStreamMapper().map(
        streams
    )

    #expect(points.count == 2)

    #expect(points[0].latitude == 47.4400)
    #expect(points[0].longitude == 25.5600)
    #expect(points[0].altitude == 792.0)
    #expect(points[0].distance == 0.0)

    #expect(points[1].latitude == 47.4410)
    #expect(points[1].longitude == 25.5610)
    #expect(points[1].altitude == 814.0)
    #expect(points[1].distance == 150.0)
}
