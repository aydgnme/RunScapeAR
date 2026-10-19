@testable import Platform
import Testing

struct SurfaceFitterTests {
    let fitter = SurfaceFitter()

    @Test func fitsRouteToSurfaceWithMargins() throws {
        let scale = fitter.fit(
            routeWidth: 0.5,
            routeDepth: 0.7,
            surfaceWidth: 0.6,
            surfaceDepth: 0.8
        )

        #expect(scale != nil)

        let fitted = try #require(scale)
        let fittedW = 0.5 * fitted
        let fittedD = 0.7 * fitted

        #expect(fittedW <= 0.6 * (1 - 2 * 0.125) + 0.001)
        #expect(fittedD <= 0.8 * (1 - 2 * 0.125) + 0.001)
    }

    @Test func preservesAspectRatio() throws {
        let scale = try #require(fitter.fit(
            routeWidth: 0.3,
            routeDepth: 0.7,
            surfaceWidth: 1.0,
            surfaceDepth: 1.0
        ))

        let ratio = (0.3 * scale) / (0.7 * scale)
        let expected: Float = 0.3 / 0.7

        #expect(abs(ratio - expected) < 0.001)
    }

    @Test func rejectsSurfaceSmallerThanMinimum() {
        let scale = fitter.fit(
            routeWidth: 0.5,
            routeDepth: 0.7,
            surfaceWidth: 0.1,
            surfaceDepth: 0.1
        )

        #expect(scale == nil)
    }

    @Test func rejectsZeroRouteSize() {
        let scale = fitter.fit(
            routeWidth: 0,
            routeDepth: 0.5,
            surfaceWidth: 1.0,
            surfaceDepth: 1.0
        )

        #expect(scale == nil)
    }

    @Test func clampsToMaximumFootprint() throws {
        let fitter = SurfaceFitter(maximumFootprint: 0.5)

        let scale = try #require(fitter.fit(
            routeWidth: 0.7,
            routeDepth: 0.7,
            surfaceWidth: 3.0,
            surfaceDepth: 3.0
        ))

        let fitted = 0.7 * scale
        #expect(fitted <= 0.5 + 0.001)
    }

    @Test func enforceMinimumFootprint() throws {
        let fitter = SurfaceFitter(minimumFootprint: 0.3)

        let scale = try #require(fitter.fit(
            routeWidth: 0.7,
            routeDepth: 0.7,
            surfaceWidth: 0.3,
            surfaceDepth: 0.3
        ))

        let fitted = 0.7 * scale
        #expect(fitted >= 0.3 - 0.001)
    }

    @Test func usesUniformScaleConstrainedBySmallestDimension() throws {
        let scale = try #require(fitter.fit(
            routeWidth: 0.7,
            routeDepth: 0.3,
            surfaceWidth: 0.5,
            surfaceDepth: 1.0
        ))

        let fittedW: Float = 0.7 * scale
        let available: Float = 0.5 * (1 - 2 * 0.125)

        #expect(fittedW <= available + 0.001)
    }

    @Test func narrowSurfaceConstrainsWideRoute() throws {
        let scale = try #require(fitter.fit(
            routeWidth: 0.7,
            routeDepth: 0.2,
            surfaceWidth: 0.4,
            surfaceDepth: 2.0
        ))

        let fittedW: Float = 0.7 * scale
        let availableW: Float = 0.4 * (1 - 2 * 0.125)

        #expect(fittedW <= availableW + 0.001)
    }
}
