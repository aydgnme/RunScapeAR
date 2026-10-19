public struct SurfaceFitter: Sendable {
    public let margin: Float
    public let minimumFootprint: Float
    public let maximumFootprint: Float
    public let minimumSurfaceDimension: Float

    public init(
        margin: Float = 0.125,
        minimumFootprint: Float = 0.15,
        maximumFootprint: Float = 1.0,
        minimumSurfaceDimension: Float = 0.2
    ) {
        self.margin = margin
        self.minimumFootprint = minimumFootprint
        self.maximumFootprint = maximumFootprint
        self.minimumSurfaceDimension = minimumSurfaceDimension
    }

    public func fit(
        routeWidth: Float,
        routeDepth: Float,
        surfaceWidth: Float,
        surfaceDepth: Float
    ) -> Float? {
        guard routeWidth > 0, routeDepth > 0 else {
            return nil
        }

        guard
            surfaceWidth >= minimumSurfaceDimension,
            surfaceDepth >= minimumSurfaceDimension
        else {
            return nil
        }

        let availableWidth = surfaceWidth * (1 - 2 * margin)
        let availableDepth = surfaceDepth * (1 - 2 * margin)

        guard availableWidth > 0, availableDepth > 0 else {
            return nil
        }

        let scaleForWidth = availableWidth / routeWidth
        let scaleForDepth = availableDepth / routeDepth
        var scale = min(scaleForWidth, scaleForDepth)

        let largestDim = max(routeWidth, routeDepth)
        let fittedLargest = largestDim * scale

        if fittedLargest < minimumFootprint {
            scale = minimumFootprint / largestDim
        } else if fittedLargest > maximumFootprint {
            scale = maximumFootprint / largestDim
        }

        return scale
    }
}
