import ContentFoundation
import StyleFoundation
import UIKit
import ViewFoundation

/**
 A container view that holds a view model and an instance of the view it can create.

 Updates that change the view type cause the previous view to be removed and discarded, and the new view to be created and added.
 Updates that do not change the view type just cause it to be updated.
 When configured with a view model, the contained view has translatesAutoresizingMaskIntoConstraints disabled,
 and it is constrained to the wrapper view with autolayout.
 */
public final class ViewModelWrapperView: PassthroughView {
    // MARK: Subviews

    public private(set) var view: UIView?

    // MARK: Properties

    public let style: Style
    public private(set) var content: Content?

    // MARK: Initialization

    public init(style: Style) {
        // Save the style:
        self.style = style

        super.init(frame: .zero)

        // Configure the view:
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelWrapperView + StyledView

extension ViewModelWrapperView: StyledView {
    public struct Style {}
}

extension ViewModelWrapperView.Style: StandardStyle {
    public static var standard: ViewModelWrapperView.Style {
        ViewModelWrapperView.Style()
    }
}

// MARK: ViewModelWrapperView + ContentConfigurable

extension ViewModelWrapperView: ContentConfigurable {
    public struct Content: Hashable {
        public init(viewModel: ViewModel?) {
            self.viewModel = viewModel
        }

        public let viewModel: ViewModel?
    }

    public func configure(for content: Content) {
        guard let viewModel = content.viewModel
        else {
            // Clear out the old view and view model:
            view?.removeFromSuperview()
            view = nil

            // Save the new content:
            self.content = content
            return
        }

        // Only update the view if the view type and subtype have not changed.
        if
            let view,
            let previousContent = self.content,
            let previousViewModel = previousContent.viewModel,
            viewModel.viewKey == previousViewModel.viewKey
        {
            // Update the view:
            viewModel.updateView(view)
        } else {
            // Make sure to get rid of the old view, if any:
            if let oldView = self.view {
                oldView.removeFromSuperview()
                self.view = nil
            }

            // Create an instance of the new view:
            let view = viewModel.createView()

            // Add the view as a subview:
            addSubview(view)

            // Constrain the view to the receiver:
            view.translatesAutoresizingMaskIntoConstraints = false
            view.constrain(to: self)

            // Save a reference to the view:
            self.view = view
        }

        // Save the new content:
        self.content = content
    }
}

// MARK: ViewModelWrapperView + DisplayableView

extension ViewModelWrapperView: DisplayableView {
    public func willDisplay() {
        guard let content, let viewModel = content.viewModel, let view
        else {
            return
        }

        viewModel.callClosure(view, for: CallableClosureKey.willDisplayView)
        if let displayableView = view as? DisplayableView {
            displayableView.willDisplay()
        }
    }

    public func didEndDisplaying() {
        guard let content, let viewModel = content.viewModel, let view
        else {
            return
        }

        viewModel.callClosure(view, for: CallableClosureKey.didEndDisplayingView)
        if let displayableView = view as? DisplayableView {
            displayableView.didEndDisplaying()
        }
    }
}

// MARK: ViewModelWrapperView + SelectableView

extension ViewModelWrapperView: SelectableView {
    public func didSelectView() {
        guard let content, let viewModel = content.viewModel, let view
        else {
            return
        }

        viewModel.callClosure(view, for: CallableClosureKey.didSelectView)
        if let selectableView = view as? SelectableView {
            selectableView.didSelectView()
        }
    }
}

// MARK: ViewModelWrapperView + HighlightableView

extension ViewModelWrapperView: HighlightableView {
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard let highlightableView = view as? HighlightableView
        else {
            return
        }

        highlightableView.setHighlighted(highlighted, animated: animated)
    }
}
