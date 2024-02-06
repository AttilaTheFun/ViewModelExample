import AssociatedObjectFoundation
import ContentFoundation
import StyleFoundation
import UIKit

public protocol ViewModelView: UIView {
    /// The view model for which the view was configured.
    var viewModel: ViewModel { get }

    /**
     Configures the receiver for the given view model.
     */
    func configure(forViewModel viewModel: ViewModel)
}

// MARK: ViewModelView

private var viewModelHandle: UInt8 = 0
private let viewModelKey = AssociatedObjectKey<ViewModel>(handle: &viewModelHandle)

public extension ViewModelView {
    var viewModel: ViewModel {
        get {
            get(viewModelKey) ?? .fallback
        }
        set {
            set(newValue, forKey: viewModelKey)
        }
    }

    func configure(forViewModel viewModel: ViewModel) {
        // Make sure the view has a matching view key.
        guard viewModel.viewKey == self.viewModel.viewKey
        else {
            preconditionFailure("View model views can only be updated with a view model of the same type")
        }

        // Update the view:
        viewModel.updateView(self)

        // Save the new view model:
        self.viewModel = viewModel
    }
}

// MARK: ViewModelView + DisplayableView

public extension ViewModelView {
    func handleWillDisplay() {
        self.viewModel.callClosure(self, for: CallableClosureKey.willDisplayView)
        guard let displayableView = self as? DisplayableView
        else {
            return
        }

        displayableView.willDisplay()
    }

    func handleDidEndDisplaying() {
        self.viewModel.callClosure(self, for: CallableClosureKey.didEndDisplayingView)
        guard let displayableView = self as? DisplayableView
        else {
            return
        }

        displayableView.didEndDisplaying()
    }
}

// MARK: ViewModelView + SelectableView

public extension ViewModelView {
    func handleDidSelectView() {
        self.viewModel.callClosure(self, for: CallableClosureKey.didSelectView)
        guard let selectableView = self as? SelectableView
        else {
            return
        }

        selectableView.didSelectView()
    }
}

// MARK: ViewModelView +

public extension ViewModelView {
    func handleSetHighlighted(_ highlighted: Bool, animated: Bool) {
        guard let highlightableView = self as? HighlightableView
        else {
            return
        }

        highlightableView.setHighlighted(highlighted, animated: animated)
    }
}

// MARK: ViewModel + ViewModelView

public extension ViewModel {
    func viewModelView() -> ViewModelView {
        let view = createView()

        // Save the initial view model:
        view.viewModel = self
        return view
    }
}

// MARK: UIView + ViewModelView

extension UIView: ViewModelView {}
