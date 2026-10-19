import Foundation
import Security

public struct KeychainTokenStore: TokenStore, Sendable {
    private let service: String
    private let account: String

    public init(
        service: String = "com.runscapear.strava",
        account: String = "strava-token"
    ) {
        self.service = service
        self.account = account
    }

    public func save(_ token: StravaToken) throws {
        let data = try JSONEncoder().encode(token)

        try? delete()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    public func load() throws -> StravaToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        guard status == errSecSuccess,
              let data = result as? Data
        else {
            if status == errSecItemNotFound {
                return nil
            }

            throw KeychainError.loadFailed(status)
        }

        return try JSONDecoder().decode(
            StravaToken.self,
            from: data
        )
    }

    public func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess ||
            status == errSecItemNotFound
        else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

public enum KeychainError: Error, Sendable {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
}
