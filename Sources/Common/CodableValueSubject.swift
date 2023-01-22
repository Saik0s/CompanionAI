import Combine
import Foundation

// MARK: - CodableValueSubject

public final class CodableValueSubject<Output: Codable>: Subject {
  public typealias Failure = Error

  private let fileURL: URL
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  private var _value: Output?
  public var value: Output? {
    get {
      if let _value { return _value }
      do {
        _value = try Output(fromFile: fileURL, decoder: decoder)
        return _value
      } catch {
        completion = .failure(error)
        return nil
      }
    }
    set {
      _value = newValue
      do {
        try newValue?.write(toFile: fileURL, encoder: encoder)
      } catch {
        completion = .failure(error)
      }
    }
  }

  private let lock = NSRecursiveLock()
  private var subscriptions = [CodableValueSubjectSubscription<Output>]()
  private var completion: Subscribers.Completion<Failure>?

  public init(fileURL: URL, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
    self.fileURL = fileURL
    self.encoder = encoder
    self.decoder = decoder
  }

  public func receive<Downstream: Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
    lock.lock(); defer { lock.unlock() }
    let subscription = CodableValueSubjectSubscription<Output>(downstream: AnySubscriber(subscriber))
    subscriber.receive(subscription: subscription)
    subscriptions.append(subscription)

    if let value {
      subscription.receive(value)
    }
    if let completion {
      subscription.receive(completion: completion)
    }
  }

  public func send(subscription: Subscription) {
    lock.lock(); defer { lock.unlock() }
    subscription.request(.unlimited)
  }

  public func send(_ value: Output) {
    lock.lock(); defer { lock.unlock() }
    self.value = value
    subscriptions.forEach { $0.receive(value) }
  }

  public func send(completion: Subscribers.Completion<Failure>) {
    lock.lock(); defer { lock.unlock() }
    self.completion = completion
    subscriptions.forEach { subscription in subscription.receive(completion: completion) }
  }
}

// MARK: - CodableValueSubjectSubscription

public final class CodableValueSubjectSubscription<Output>: Subscription {
  public typealias Failure = Error

  private let downstream: AnySubscriber<Output, Failure>
  private var isCompleted = false
  private var demand: Subscribers.Demand = .none

  public init(downstream: AnySubscriber<Output, Failure>) {
    self.downstream = downstream
  }

  public func request(_ newDemand: Subscribers.Demand) {
    demand += newDemand
  }

  public func cancel() {
    isCompleted = true
  }

  public func receive(_ value: Output) {
    guard !isCompleted, demand > 0 else { return }

    demand += downstream.receive(value)
    demand -= 1
  }

  public func receive(completion: Subscribers.Completion<Failure>) {
    guard !isCompleted else { return }
    isCompleted = true
    downstream.receive(completion: completion)
  }
}
