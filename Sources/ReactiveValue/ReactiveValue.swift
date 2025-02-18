import Combine
import Foundation

/// A property wrapper that provides reactive management for a Codable & Equatable value,
/// using a ReactiveValueProviding provider such as UserDefaults.
@propertyWrapper
public struct ReactiveValue<Value> where Value: Codable, Value: Equatable {
    private var publisher: AnyReactiveValuePublisher<Value>

    /// Initializes the ReactiveValue with the given default value, key, and provider.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value, which is used as the default if no value exists for the key.
    ///   - key: The key used to store and retrieve the value.
    ///   - provider: The provider used to retrieve and store the value (default is UserDefaults.standard).
    public init(
        wrappedValue defaultValue: Value,
        _ key: String,
        provider: ReactiveValueProviding = UserDefaults.standard
    ) {
        self.publisher = provider.publisher(forKey: key, default: defaultValue)
    }

    /// The wrapped value managed by this property wrapper.
    public var wrappedValue: Value {
        get { publisher.value }
        set { publisher.value = newValue }
    }

    /// The projected value exposing the underlying AnyReactiveValuePublisher.
    public var projectedValue: AnyReactiveValuePublisher<Value> { publisher }
}

/// The ReactiveValueProviding protocol defines a method for generating a publisher
/// that monitors changes to a value associated with a specific key.
public protocol ReactiveValueProviding {
    /// Creates a publisher that emits updates for the value associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to observe.
    ///   - defaultValue: The default value to use if the key does not exist.
    /// - Returns: An AnyReactiveValuePublisher that emits updates for the specified key.
    func publisher<Output: Codable & Equatable>(forKey key: String, default defaultValue: Output)
        -> AnyReactiveValuePublisher<Output>
}

/// The ReactiveValuePublisherProtocol defines a Publisher that manages a value
/// of type Output which conforms to Codable and Equatable.
public protocol ReactiveValuePublisherProtocol: AnyObject, Combine.Publisher
where Output: Codable & Equatable {
    /// The current value managed by the publisher.
    var value: Output { get set }
}

/// A type-erased publisher that wraps a concrete ReactiveValuePublisherProtocol,
/// providing a unified interface.
public class AnyReactiveValuePublisher<Value: Codable & Equatable>: ReactiveValuePublisherProtocol {
    public typealias Output = Value
    public typealias Failure = Never

    private let _getValue: () -> Value
    private let _setValue: (Value) -> Void
    private let _receive: (AnySubscriber<Value, Never>) -> Void

    /// The current value, accessible for reading and updating.
    public var value: Value {
        get { _getValue() }
        set { _setValue(newValue) }
    }

    /// Initializes a type-erased publisher wrapping the given concrete publisher.
    ///
    /// - Parameter publisher: A concrete publisher conforming to ReactiveValuePublisherProtocol.
    public init<P: ReactiveValuePublisherProtocol>(_ publisher: P)
    where P.Output == Value, P.Failure == Never {
        _getValue = { publisher.value }
        _setValue = { publisher.value = $0 }
        _receive = { subscriber in
            publisher.receive(subscriber: subscriber)
        }
    }

    /// Subscribes the given subscriber to receive the current value and future updates.
    ///
    /// - Parameter subscriber: The subscriber that will receive published values.
    public func receive<S>(subscriber: S)
    where S: Subscriber, Never == S.Failure, Value == S.Input {
        _receive(AnySubscriber(subscriber))
    }
}
