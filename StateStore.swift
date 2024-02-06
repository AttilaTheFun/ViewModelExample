import Combine

public protocol StateStore {
    associatedtype State: Equatable

    /**
     The current value of the state.
     */
    var state: State { get }

    /**
     A publisher for changes to the state.
     */
    var statePublisher: AnyPublisher<State, Never> { get }
}

public final class DefaultStateStore<State> where State: Equatable {
    private let stateSubject: CurrentValueSubject<State, Never>

    public init(initialState: State) {
        self.stateSubject = CurrentValueSubject(initialState)
    }

    public func accept(state: State) {
        self.stateSubject.send(state)
    }
}

extension DefaultStateStore: StateStore {
    public var state: State {
        self.stateSubject.value
    }

    public var statePublisher: AnyPublisher<State, Never> {
        self.stateSubject.eraseToAnyPublisher()
    }
}
