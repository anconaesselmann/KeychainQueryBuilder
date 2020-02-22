import Foundation

public enum KeychainMatchLimit {
    case one
    case all

    public var kSecMatchlimit: CFString {
        switch self {
        case .one:
            return kSecMatchLimitOne
        case .all:
            return kSecMatchLimitAll
        }
    }
}

public struct KeychainQueryBuilder {

    public enum DataType {
        case internetPassword
        case genericPassword
        case certificate
        case key
        case identity

        var kSecClass: CFString {
            switch self {
            case .internetPassword:
                return kSecClassInternetPassword
            case .genericPassword:
                return kSecClassGenericPassword
            case .certificate:
                return kSecClassCertificate
            case .key:
                return kSecClassKey
            case .identity:
                return kSecClassIdentity
            }
        }
    }

    private let query: [String: Any]

    public init(type: DataType) {
        query = [kSecClass as String: type.kSecClass]
    }

    public init() {
        query = [:]
    }

    private init(query: [String: Any]) {
        self.query = query
    }

    public func account(_ account: String) -> Self {
        return updated(key: kSecAttrAccount as String, value: account)
    }

    public func data(_ data: Data) -> Self {
        return updated(key: kSecValueData as String, value: data)
    }

    public func data(fromString stringValue: String) -> Self {
        guard let data = stringValue.data(using: String.Encoding.utf8) else {
            return self
        }
        return self.data(data)
    }

    public func matchLimit(_ matchLimit: KeychainMatchLimit) -> Self {
        return updated(key: kSecMatchLimit as String, value: matchLimit.kSecMatchlimit)
    }

    public func returnAttributes(_ isReturningAttributes: Bool = true) -> Self {
        return updated(key: kSecReturnAttributes as String, value: isReturningAttributes)
    }

    public func returnData(_ isReturningData: Bool = true) -> Self {
        return updated(key: kSecReturnData as String, value: isReturningData)
    }

    public func build() -> CFDictionary {
        return query as CFDictionary
    }

    private func updated(key: String, value: Any) -> Self {
        return Self(query: query.updated(key: key, value: value))
    }
}

extension Dictionary where Key == String, Value == Any {
    func updated(key: String, value: Any) -> Dictionary<String, Any> {
        var mutable = self
        mutable[key] = value
        return mutable
    }
}

public enum KeychainQueryResult {
    public struct Result {
        public let data: Data
    }

    case none
    case one(Result)
    case many([Result])
    case error(Error)
}

public struct KeychainQueryResultBuilder {

    public enum Error: Swift.Error {
        case unhandledError(status: OSStatus)
        case unexpectedFormat
        case unexpectedlyNoData
        case multipleResultsNotSupportedYet
    }

    private let query: CFDictionary

    public init(forQuery query: CFDictionary) {
        self.query = query
    }

    func attributeIsSet(_ attribute: CFString, in query: CFDictionary) -> Bool {
        return (query as? [String: Any])?[attribute as String] != nil
    }

    public func result(for item: CFTypeRef?, status: OSStatus) -> KeychainQueryResult {
        guard status != errSecItemNotFound else {
            return .none
        }
        guard status == errSecSuccess else {
            return .error(Error.unhandledError(status: status))
        }

        if attributeIsSet(KeychainMatchLimit.all.kSecMatchlimit, in: query) {
            return .error(Error.multipleResultsNotSupportedYet)
        } else {
            return extractOneElement(from: item)
        }
    }

    private func extractOneElement(from item: CFTypeRef?) -> KeychainQueryResult {
        guard let retrievedItem = item as? [String : Any] else {
            return .error(Error.unexpectedFormat)
        }
        guard let data = retrievedItem[kSecValueData as String] as? Data else {
            return .error(Error.unexpectedlyNoData)
        }
        // let account = retrievedItem[kSecAttrAccount as String] as? String
        let result = KeychainQueryResult.Result(data: data)
        return .one(result)
    }

}
