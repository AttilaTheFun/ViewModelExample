import ContentFoundation
import StyleFoundation
import UIKit
import ViewFoundation

/**
 A container view that provides an attachment point for a context menu.
 If the view model has a closureContextMenuInteractor, this view adds a UIContextMenuInteraction for it.
 NOTE: In order for the context menu to function, the view cannot pass through touches to views behind it.
 */
public final class ViewModelContextMenuView: UIView {
    // MARK: Subviews

    private let wrapperView = ViewModelWrapperView()

    // MARK: Properties

    public let style: Style

    private var closureContextMenuInteractor: ClosureContextMenuInteractor?
    private var contextMenuInteraction: UIContextMenuInteraction?

    // MARK: Initialization

    public init(style: Style) {
        // Save the style:
        self.style = style

        super.init(frame: .zero)

        // Configure the views:
        translatesAutoresizingMaskIntoConstraints = false

        // Create the view hierarchy:
        addSubview(self.wrapperView)

        // Create the constraints:
        self.wrapperView.constrain(to: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelContextMenuView + StyledView

extension ViewModelContextMenuView: StyledView {
    public struct Style {}
}

extension ViewModelContextMenuView.Style: StandardStyle {
    public static var standard: ViewModelContextMenuView.Style {
        ViewModelContextMenuView.Style()
    }
}

// MARK: ViewModelContextMenuView + ContentConfigurable

extension ViewModelContextMenuView: ContentConfigurable {
    public typealias Content = ViewModelWrapperView.Content

    public func configure(for content: ViewModelWrapperView.Content) {
        // Configure the wrapper view:
        self.wrapperView.configure(for: content)

        // Remove the context menu interaction and its identifier differs from that on the view model (if any).
        if
            let contextMenuInteraction,
            let closureContextMenuInteractor,
            closureContextMenuInteractor.identifier != content.viewModel?.closureContextMenuInteractor?.identifier
        {
            removeInteraction(contextMenuInteraction)
            self.contextMenuInteraction = nil
            self.closureContextMenuInteractor = nil
        }

        // Add the context menu interaction if we don't have a context menu interaction and the view model has one.
        if
            contextMenuInteraction == nil,
            let closureContextMenuInteractor = content.viewModel?.closureContextMenuInteractor
        {
            let contextMenuInteraction = UIContextMenuInteraction(delegate: closureContextMenuInteractor)
            addInteraction(contextMenuInteraction)
            self.contextMenuInteraction = contextMenuInteraction
            self.closureContextMenuInteractor = closureContextMenuInteractor
            closureContextMenuInteractor.contextMenuView = self.wrapperView
        }
    }
}

// MARK: ViewModelContextMenuView + DisplayableView

extension ViewModelContextMenuView: DisplayableView {
    public func willDisplay() {
        self.wrapperView.willDisplay()
    }

    public func didEndDisplaying() {
        self.wrapperView.didEndDisplaying()
    }
}

// MARK: ViewModelContextMenuView + HighlightableView

extension ViewModelContextMenuView: HighlightableView {
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.wrapperView.setHighlighted(highlighted, animated: animated)
    }
}

// MARK: ViewModelContextMenuView + SelectableView

extension ViewModelContextMenuView: SelectableView {
    public func didSelectView() {
        self.wrapperView.didSelectView()
    }
}

// MARK: ViewModel + ContextMenuView

public extension ViewModel {
    func inContextMenuView() -> ViewModel {
        ViewModelBuilder<ViewModelContextMenuView>(
            identity: "view-model-context-menu-view",
            content: .init(viewModel: self)
        )
        .build()
    }
}
