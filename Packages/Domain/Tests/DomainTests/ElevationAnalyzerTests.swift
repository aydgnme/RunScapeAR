import Domain
import Testing

@Suite("ElevationAnalyzer")
struct ElevationAnalyzerTests {
    private let analyzer = ElevationAnalyzer()

    @Test
    func returnsNilForEmptyPoints() {
        let result = analyzer.analyze(points: [])
        #expect(result == nil)
    }

    @Test
    func returnsNilForSinglePoint() {
        let result = analyzer.analyze(points: [
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 0)
        ])
        #expect(result == nil)
    }

    @Test
    func computesTotalDistance() throws {
        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 500),
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 1000)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.totalDistance == 1000)
    }

    @Test
    func computesElevationGainAndLoss() throws {
        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 150, distance: 500),
            TrackPoint(latitude: 0, longitude: 0, altitude: 120, distance: 1000),
            TrackPoint(latitude: 0, longitude: 0, altitude: 180, distance: 1500)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.elevationGain == 110.0)
        #expect(stats.elevationLoss == 30.0)
    }

    @Test
    func computesMinMaxAltitude() throws {
        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 200, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 50, distance: 500),
            TrackPoint(latitude: 0, longitude: 0, altitude: 300, distance: 1000)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.minimumAltitude == 50.0)
        #expect(stats.maximumAltitude == 300.0)
    }

    @Test
    func computesMaximumGradient() throws {
        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 110, distance: 100),
            TrackPoint(latitude: 0, longitude: 0, altitude: 130, distance: 200)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.maximumGradient == 20.0)
    }

    @Test
    func computesSteepestDescent() throws {
        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 200, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 170, distance: 100),
            TrackPoint(latitude: 0, longitude: 0, altitude: 180, distance: 200)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.steepestDescent == -30.0)
    }

    @Test
    func skipsGradientForTinySegments() throws {
        let analyzer = ElevationAnalyzer(minimumSegmentDistance: 10.0)

        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 200, distance: 0.5),
            TrackPoint(latitude: 0, longitude: 0, altitude: 210, distance: 100)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.elevationGain == 110.0)
        #expect(stats.maximumGradient > 0)
        #expect(stats.maximumGradient < 15)
    }

    @Test
    func clamsGradientAtCap() throws {
        let analyzer = ElevationAnalyzer(gradientCap: 50.0)

        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 0, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 10)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.maximumGradient == 50.0)
    }

    @Test
    func flatRouteHasZeroGradients() throws {
        let points = [
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 0),
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 500),
            TrackPoint(latitude: 0, longitude: 0, altitude: 100, distance: 1000)
        ]

        let stats = try #require(analyzer.analyze(points: points))
        #expect(stats.elevationGain == 0)
        #expect(stats.elevationLoss == 0)
        #expect(stats.maximumGradient == 0)
        #expect(stats.steepestDescent == 0)
    }
}
