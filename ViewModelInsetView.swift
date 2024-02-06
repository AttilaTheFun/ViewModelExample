import ContentFoundation
import StyleFoundation
import UIKit
import ViewFoundation

/**
 Renders a single view model as a subview applying the style's insets.
 */
open class ViewModelInsetView: PassthroughView {
    // MARK: Subviews

    private var wrapperView = ViewModelWrapperView()

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
        self.wrapperView.constrain(to: self, directionalInsets: style.insets)
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelInsetView + StyledView

extension ViewModelInsetView: StyledView {
    public struct Style {
        public var insets: NSDirectionalEdgeInsets = .zero
    }
}

extension ViewModelInsetView.Style: StandardStyle {
    public static var standard: ViewModelInsetView.Style {
        ViewModelInsetView.Style()
    }

    public func with(insets: NSDirectionalEdgeInsets) -> Self {
        var style = self
        style.insets = insets
        return style
    }
}

// MARK: ViewModelInsetView + ContentConfigurable

extension ViewModelInsetView: ContentConfigurable {
    public typealias Content = ViewModel

    public func configure(for content: Content) {
        self.wrapperView.configure(for: .init(viewModel: content))
    }
}

// MARK: ViewModelInsetView + DisplayableView

extension ViewModelInsetView: DisplayableView {
    public func willDisplay() {
        self.wrapperView.willDisplay()
    }

    public func didEndDisplaying() {
        self.wrapperView.didEndDisplaying()
    }
}

// MARK: ViewModelInsetView + HighlightableView

extension ViewModelInsetView: HighlightableView {
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.wrapperView.setHighlighted(highlighted, animated: animated)
    }
}

// MARK: ViewModelInsetView + SelectableView

extension ViewModelInsetView: SelectableView {
    public func didSelectView() {
        self.wrapperView.didSelectView()
    }
}

// MARK: ViewModel + Insets

public extension ViewModel {
    func with(insets: NSDirectionalEdgeInsets) -> ViewModel {
        var style = ViewModelInsetView.Style.standard
        style.insets = insets
        return ViewModelBuilder<ViewModelInsetView>(
            identity: identity,
            style: style,
            content: self
        )
        .build()
    }
}
