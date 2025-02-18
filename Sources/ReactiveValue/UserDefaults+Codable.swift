import Foundation

extension UserDefaults {
    /// Retrieves a Codable value from UserDefaults.
    ///
    /// If the key does not exist or decoding fails, the specified default value is returned.
    ///
    /// - Parameters:
    ///   - type: The type of the value to retrieve. The type is inferred from the argument.
    ///   - key: The key for the stored value.
    ///   - defaultValue: The default value to return if the key does not exist.
    /// - Returns: The value of the specified type, or the defaultValue if decoding fails.
    public func value<Value: Codable>(
        type: Value.Type = Value.self,
        forKey key: String,
        default defaultValue: Value
    ) -> Value {
        guard let data = object(forKey: key) as? Data else { return defaultValue }

        let decoder = JSONDecoder()
        let value = try? decoder.decode(Value.self, from: data)
        return value ?? defaultValue
    }

    /// Retrieves a Codable value from UserDefaults.
    ///
    /// If the key does not exist or decoding fails, nil is returned.
    ///
    /// - Parameters:
    ///   - type: The type of the value to retrieve.
    ///   - key: The key for the stored value.
    /// - Returns: The value of the specified type, or nil if it cannot be retrieved.
    public func value<Value: Codable>(type: Value.Type, forKey key: String) -> Value? {
        guard let data = object(forKey: key) as? Data else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode(Value.self, from: data)
    }

    /// Saves a Codable value to UserDefaults.
    ///
    /// If the value is nil, the data for the corresponding key is removed.
    ///
    /// - Parameters:
    ///   - value: The value to save. If nil is provided, the key's value is removed.
    ///   - key: The key under which the value is saved.
    public func setValue<Value: Codable>(_ value: Value?, forKey key: String) {
        guard let value = value else {
            removeObject(forKey: key)
            return
        }

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            set(data, forKey: key)
        } catch {
            removeObject(forKey: key)
        }
    }
}
