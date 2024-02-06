public protocol ContentPresenter {
    associatedtype State: Equatable
    associatedtype Content: Hashable

    func present(state: State) -> Content
}

public final class DefaultContentPresenter<State, Content> where State: Equatable, Content: Hashable {
    private let transform: (State) -> Content

    public init(transform: @escaping (State) -> Content) {
        self.transform = transform
    }
}

extension DefaultContentPresenter: ContentPresenter {
    public func present(state: State) -> Content {
        self.transform(state)
    }
}
