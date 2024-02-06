import ContentFoundation
import StyleFoundation
import UIKit
import ViewFoundation

/**
 Renders a collection of view models in a stackview.
 This doesn't do any fancy diffing - it just adds / removes / replaces views as necessary to match the given models.
 If performance proves problematic, we could look at improving this.
 */
open class ViewModelStackView: PassthroughStackView {
    // MARK: Subviews

    private var wrapperViews = [ViewModelWrapperView]()

    // MARK: Properties

    public let style: Style

    // MARK: Initialization

    public required init(style: Style) {
        // Save the style:
        self.style = style

        super.init(frame: .zero)

        // Configure the view:
        translatesAutoresizingMaskIntoConstraints = false
        axis = style.axis
        alignment = style.alignment
        spacing = style.spacing
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelStackView + StyledView

extension ViewModelStackView: StyledView {
    public struct Style {
        public var axis: NSLayoutConstraint.Axis = .horizontal
        public var alignment: UIStackView.Alignment = .fill
        public var spacing: CGFloat = .zero
        public var distribution: UIStackView.Distribution = .fill
    }
}

extension ViewModelStackView.Style: StandardStyle {
    public static var standard: ViewModelStackView.Style {
        ViewModelStackView.Style()
    }

    public func with(axis: NSLayoutConstraint.Axis) -> Self {
        var style = self
        style.axis = axis
        return style
    }

    public func with(spacing: CGFloat) -> Self {
        var style = self
        style.spacing = spacing
        return style
    }
}

// MARK: ViewModelStackView + ContentConfigurable

extension ViewModelStackView: ContentConfigurable {
    public struct Content: Hashable {
        public init(viewModels: [ViewModel]) {
            self.viewModels = viewModels
        }

        public let viewModels: [ViewModel]
    }

    public func configure(for content: Content) {
        // Pop wrapper views and remove them as subviews until they match the model count.
        while self.wrapperViews.count > content.viewModels.count {
            let wrapperView = self.wrapperViews.popLast()
            wrapperView?.removeFromSuperview()
        }

        // Append wrapper views and add them as arranged subviews until they match the model count.
        while self.wrapperViews.count < content.viewModels.count {
            let wrapperView = ViewModelWrapperView()
            self.wrapperViews.append(wrapperView)
            addArrangedSubview(wrapperView)
        }

        // Update the wrapper views:
        for (wrapperView, viewModel) in zip(self.wrapperViews, content.viewModels)
            where wrapperView.content?.viewModel != viewModel {
            wrapperView.configure(for: .init(viewModel: viewModel))
        }
    }
}
