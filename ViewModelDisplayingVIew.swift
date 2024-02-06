import ContentFoundation
import StyleFoundation
import UIKit
import ViewFoundation

/**
 A container view that emulates the will display / did end displaying callbacks a view model would receive when displayed in a  table / collection view
 by relaying when the receiver is removed from / added to a window.
 */
public final class ViewModelDisplayingView: PassthroughView {
    // MARK: Subviews

    private let wrapperView = ViewModelWrapperView()

    // MARK: Properties

    public let style: Style

    // MARK: Initialization

    public required init(style: Style) {
        // Save the style:
        self.style = style

        super.init(frame: .zero)

        // Configure the view:
        translatesAutoresizingMaskIntoConstraints = false

        // Create the view hierarchy:
        addSubview(self.wrapperView)

        // Constrain the subview:
        self.wrapperView.constrain(to: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.wrapperView.willDisplay()
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            self.wrapperView.didEndDisplaying()
        }
    }
}

// MARK: ViewModelDisplayingView + StyledView

extension ViewModelDisplayingView: StyledView {
    public struct Style {}
}

extension ViewModelDisplayingView.Style: StandardStyle {
    public static var standard: ViewModelDisplayingView.Style {
        ViewModelDisplayingView.Style()
    }
}

// MARK: ViewModelDisplayingView + ContentConfigurable

extension ViewModelDisplayingView: ContentConfigurable {
    public typealias Content = ViewModelWrapperView.Content

    public func configure(for content: ViewModelWrapperView.Content) {
        self.wrapperView.configure(for: content)
    }
}

// MARK: ViewModel + DisplayingView

public extension ViewModel {
    func inDisplayingView() -> ViewModel {
        ViewModelBuilder<ViewModelDisplayingView>(
            identity: identity,
            style: .standard,
            content: .init(viewModel: self)
        )
        .build()
    }
}
