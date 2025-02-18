import Combine
import Foundation

/// Extension that implements the ReactiveValueProviding protocol for UserDefaults,
/// providing a Combine publisher for observing value changes.
extension UserDefaults: ReactiveValueProviding {
    /// Creates a publisher that monitors changes to the specified key in UserDefaults.
    ///
    /// - Parameters:
    ///   - key: The key in UserDefaults to observe.
    ///   - defaultValue: The default value to return if the key does not exist.
    /// - Returns: An `AnyReactiveValuePublisher` that emits updates for the specified key.
    public func publisher<Output: Codable & Equatable>(
        forKey key: String,
        default defaultValue: Output
    ) -> AnyReactiveValuePublisher<Output> {
        let concretePublisher = UserDefaults.Publisher<Output>(
            key: key, default: defaultValue, userDefaults: self)
        return AnyReactiveValuePublisher(concretePublisher)
    }
}

/// Extension that provides a Combine-based publisher for a specific key in UserDefaults.
extension UserDefaults {
    /// A publisher that emits updates for a value stored in UserDefaults.
    ///
    /// This class observes the value associated with a specified key in UserDefaults and
    /// emits its current and future values via a `CurrentValueSubject`.
    public class Publisher<Output>: NSObject, ReactiveValuePublisherProtocol
    where Output: Codable, Output: Equatable {
        public typealias Failure = Never

        private let key: String
        private let defaultValue: Output
        private let userDefaults: UserDefaults
        private let subject: CurrentValueSubject<Output, Never>

        /// The current value associated with the specified key in UserDefaults.
        ///
        /// Setting a new value updates the stored value in UserDefaults and emits the change if the value is different.
        public var value: Output {
            get { subject.value }
            set {
                if newValue != subject.value {
                    subject.value = newValue
                    userDefaults.setValue(newValue, forKey: key)
                }
            }
        }

        /// Initializes a new publisher for a given key in UserDefaults.
        ///
        /// - Parameters:
        ///   - key: The key in UserDefaults to observe.
        ///   - defaultValue: The default value used if no value is stored for the key.
        ///   - userDefaults: The UserDefaults instance to use (default is `.standard`).
        public init(
            key: String,
            default defaultValue: Output,
            userDefaults: UserDefaults = UserDefaults.standard
        ) {
            self.key = key
            self.defaultValue = defaultValue
            self.userDefaults = userDefaults
            self.subject = .init(
                userDefaults.value(type: Output.self, forKey: key, default: defaultValue))
            super.init()
            userDefaults.addObserver(self, forKeyPath: key, options: .new, context: nil)
        }

        deinit {
            userDefaults.removeObserver(self, forKeyPath: key)
        }

        /// Observes changes to the value in UserDefaults and updates the publisher accordingly.
        ///
        /// - Parameters:
        ///   - keyPath: The key that changed.
        ///   - object: The object that changed.
        ///   - change: A dictionary containing details about the change.
        ///   - context: Additional context information.
        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            if keyPath == key {
                let newValue =
                    (change?[.newKey] as? Data)
                    .flatMap { try? JSONDecoder().decode(Output.self, from: $0) }
                    ?? defaultValue
                if newValue != subject.value {
                    subject.value = newValue
                }
            }
        }

        /// Subscribes the given subscriber to receive the current value and future updates.
        ///
        /// - Parameter subscriber: The subscriber that will receive the published values.
        public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
            subject.receive(subscriber: subscriber)
        }
    }
}
