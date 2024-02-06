import ContentFoundation
import UIKit

/**
 The ViewModelBuilder is used to build view model instances.
 The view type can be constructed by the view models.
 */
public class ViewModelBuilder<View> where View: UIView {
    // MARK: Properties

    let identity: String
    let viewSubtype: String
    let content: AnyHashable

    private let creator: () -> View
    private var updateClosures: [String: UpdateClosure<View>]
    private var callableClosures: [String: CallableClosure<View>]
    private var metadata: [String: Any]

    // MARK: Initialization

    public init(
        identity: String,
        viewSubtype: String,
        content: AnyHashable,
        updateClosures: [String: UpdateClosure<View>] = [:],
        callableClosures: [String: CallableClosure<View>] = [:],
        metadata: [String: Any] = [:],
        creator: @escaping () -> View
    ) {
        self.identity = identity
        self.viewSubtype = viewSubtype
        self.content = content
        self.updateClosures = updateClosures
        self.callableClosures = callableClosures
        self.metadata = metadata
        self.creator = creator
    }

    // MARK: Interface

    /**
     Sets the update closure for the given key.
     */
    @discardableResult
    public func withUpdateClosure(_ closure: UpdateClosure<View>?, for key: String) -> Self {
        self.updateClosures[key] = closure
        return self
    }

    /**
     Sets the callable closure for the given key.
     */
    @discardableResult
    public func withCallableClosure(_ closure: CallableClosure<View>?, for key: String) -> Self {
        self.callableClosures[key] = closure
        return self
    }

    /**
     Sets the metadata value for the given key.
     */
    @discardableResult
    public func withValue(_ value: Any?, for key: String) -> Self {
        self.metadata[key] = value
        return self
    }

    /**
     Builds the view model from the view model builder.
     */
    public func build() -> ViewModel {
        // Create the updater closure:
        let typedUpdateClosures = self.updateClosures
        let updater: (UIView) -> Void = { view in
            guard let typedView = view as? View
            else {
                return assertionFailure("View \(view) was not of type \(View.self).")
            }

            typedUpdateClosures.values.forEach { $0(typedView) }
        }

        // Create the creator closure:
        let typedCreator = creator
        let creator: () -> UIView = {
            let view = typedCreator()
            updater(view)
            return view
        }

        // Erase the callable closures:
        let erasedCallableClosures = self.callableClosures.mapValues { typedClosure -> (UIView) -> Void in { view in
                guard let typedView = view as? View else {
                    return assertionFailure("View \(view) was not of type \(View.self).")
                }

                typedClosure(typedView)
            }
        }

        return ViewModel(
            identity: self.identity,
            viewKey: ViewKey(viewType: View.self, viewSubtype: self.viewSubtype),
            content: self.content,
            metadata: self.metadata,
            creator: creator,
            updater: updater,
            callableClosures: erasedCallableClosures
        )
    }
}
