import DiffableDataSource
import StyleFoundation
import UIKit
import ViewFoundation

/**
 A type-erased, built view model.
 Two view models are considered equivalent if their identity, view type, and content are equal.
 */
public struct ViewModel {
    /// An identity, unique between the view and its siblings in the view hierarchy, used for diffing and in hashable
    /// calculations.
    public let identity: String

    /// Combines the type of the view with the view subtype - used when considering a view for reuse and in hashable
    /// calculations.
    public let viewKey: ViewKey

    /// The type-erased view's content used in hashable calculations.
    private let content: AnyHashable

    /// Type-erased metadata. Not included in hashable calculations.
    private let metadata: [String: Any]

    /// A closure that builds an instance of the view.
    private let creator: () -> UIView

    /// A closure that updates a type-erased instance of the built view for the metadata.
    private let updater: (UIView) -> Void

    /// A dictionary mapping callable closure keys to the erased, callable closures.
    private let callableClosures: [String: (UIView) -> Void]

    // MARK: Initialization

    init(
        identity: String,
        viewKey: ViewKey,
        content: AnyHashable,
        metadata: [String: Any],
        creator: @escaping () -> UIView,
        updater: @escaping (UIView) -> Void,
        callableClosures: [String: (UIView) -> Void]
    ) {
        self.identity = identity
        self.viewKey = viewKey
        self.content = content
        self.metadata = metadata
        self.creator = creator
        self.updater = updater
        self.callableClosures = callableClosures
    }

    // MARK: Interface

    /**
     Creates a new instance of the built view and updates it.
     */
    public func createView() -> UIView {
        self.creator()
    }

    /**
     Updates an existing instance of the built view.
     */
    public func updateView(_ view: UIView) {
        self.updater(view)
    }

    /**
     Calls the closure with the given key on the given view (if one exists).
     */
    public func callClosure(_ view: UIView, for key: String) {
        if let callableClosure = callableClosure(for: key) {
            callableClosure(view)
        }
    }

    /**
     Retrieves the metadata value for the given key.
     */
    public func typedValue<T>(for key: String) -> T? {
        guard let value = metadata[key]
        else {
            return nil
        }

        guard let typedValue = value as? T
        else {
            assertionFailure("Metadata value \(value) was not of type \(T.self)")
            return nil
        }

        return typedValue
    }

    /**
     Retrieves the callable closure for the given key.
     */
    public func callableClosure(for key: String) -> ((UIView) -> Void)? {
        self.callableClosures[key]
    }
}

// MARK: ViewModel + Hashable

extension ViewModel: Hashable {
    public static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
        lhs.identity == rhs.identity
            && lhs.viewKey == rhs.viewKey
            && lhs.content == rhs.content
    }

    public func hash(into hasher: inout Hasher) {
        self.identity.hash(into: &hasher)
        self.viewKey.hash(into: &hasher)
        self.content.hash(into: &hasher)
    }
}

// MARK: ViewModel + Identifiable

extension ViewModel: Identifiable {
    public var id: String {
        self.identity
    }
}

// MARK: ViewModel + ItemType

extension ViewModel: ItemType {}

// MARK: ViewModel + Fallback

public extension ViewModel {
    static var fallback: ViewModel {
        ViewModelBuilder<FallbackViewModelView>(
            identity: "fallback",
            content: .init()
        )
        .build()
    }
}
