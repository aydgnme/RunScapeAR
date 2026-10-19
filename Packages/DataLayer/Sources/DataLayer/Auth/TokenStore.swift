public protocol TokenStore: Sendable {
    func save(_ token: StravaToken) throws
    func load() throws -> StravaToken?
    func delete() throws
}
