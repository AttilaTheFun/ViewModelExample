import ContentFoundation
import StyleFoundation
import UIKit
import ViewFoundation

/**
 A container view that makes a view behave like a button.
 This embeds a button behind the wrapped view which receives touches that pass through it.
 (You can use PassthroughView or disable user interaction on your view to allow the touches to pass through unimpeded.)

 When the button is tapped, the wrapped view's didSelectView method is called.
 When the button is highlighted, these events are forwarded to the wrapped view.

 If the view model has a context menu, that will be attached too.
 */
public final class ViewModelButtonView: UIView {
    // MARK: Subviews

    private let button = HighlightDelegatingButton()
    private let viewModelView: ViewModelView

    // MARK: Properties

    public let style: Style

    private var closureContextMenuInteractor: ClosureContextMenuInteractor?
    private var contextMenuInteraction: UIContextMenuInteraction?

    // MARK: Initialization

    public init(style: Style) {
        // Save the style:
        self.style = style

        // Create the views:
        self.viewModelView = style.initialViewModel.viewModelView()

        super.init(frame: .zero)

        // Configure the views:
        translatesAutoresizingMaskIntoConstraints = false
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        self.button.highlightableView = self

        // Create the view hierarchy:
        addSubview(self.button)
        addSubview(self.viewModelView)

        // Create the constraints:
        self.button.constrain(to: self)
        self.viewModelView.constrain(to: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    @objc
    private func buttonTapped() {
        didSelectView()
    }
}

// MARK: ViewModelButtonView + StyledView

extension ViewModelButtonView: StyledView {
    public struct Style {
        var initialViewModel = ViewModel.fallback
    }
}

extension ViewModelButtonView.Style: StandardStyle {
    public static var standard: ViewModelButtonView.Style {
        ViewModelButtonView.Style()
    }

    public func with(initialViewModel: ViewModel) -> Self {
        var style = self
        style.initialViewModel = initialViewModel
        return style
    }
}

// MARK: ViewModelButtonView + ContentConfigurable

extension ViewModelButtonView: ContentConfigurable {
    public struct Content: Hashable {
        public init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        public let viewModel: ViewModel
    }

    public func configure(for content: Content) {
        self.viewModelView.configure(forViewModel: content.viewModel)

        // Remove the context menu interaction and its identifier differs from that on the view model (if any).
        if
            let contextMenuInteraction,
            let closureContextMenuInteractor,
            closureContextMenuInteractor.identifier != content.viewModel.closureContextMenuInteractor?.identifier
        {
            removeInteraction(contextMenuInteraction)
            self.contextMenuInteraction = nil
            self.closureContextMenuInteractor = nil
        }

        // Add the context menu interaction if we don't have a context menu interaction and the view model has one.
        if
            contextMenuInteraction == nil,
            let closureContextMenuInteractor = content.viewModel.closureContextMenuInteractor
        {
            let contextMenuInteraction = UIContextMenuInteraction(delegate: closureContextMenuInteractor)
            addInteraction(contextMenuInteraction)
            self.contextMenuInteraction = contextMenuInteraction
            self.closureContextMenuInteractor = closureContextMenuInteractor
            closureContextMenuInteractor.contextMenuView = self.viewModelView
        }
    }
}

// MARK: ViewModelButtonView + DisplayableView

extension ViewModelButtonView: DisplayableView {
    public func willDisplay() {
        self.viewModelView.handleWillDisplay()
    }

    public func didEndDisplaying() {
        self.viewModelView.handleDidEndDisplaying()
    }
}

// MARK: ViewModelButtonView + SelectableView

extension ViewModelButtonView: SelectableView {
    public func didSelectView() {
        self.viewModelView.handleDidSelectView()
    }
}

// MARK: ViewModelButtonView + HighlightableView

extension ViewModelButtonView: HighlightableView {
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.viewModelView.handleSetHighlighted(highlighted, animated: animated)
    }
}

// MARK: HighlightDelegatingButton

private final class HighlightDelegatingButton: UIButton {
    weak var highlightableView: HighlightableView?

    override var isHighlighted: Bool {
        didSet {
            self.highlightableView?.setHighlighted(self.isHighlighted, animated: true)
        }
    }
}

// MARK: ViewModel + ButtonView

public extension ViewModel {
    func inButtonView() -> ViewModel {
        let style = ViewModelButtonView.Style.standard
            .with(initialViewModel: self)
        return ViewModelBuilder<ViewModelButtonView>(
            identity: "view-model-button-view",
            style: style,
            content: .init(viewModel: self)
        )
        .build()
    }
}
