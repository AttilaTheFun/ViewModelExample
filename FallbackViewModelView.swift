import ContentFoundation
import StyleFoundation
import UIKit

public final class FallbackViewModelView: UIView {
    public let style: Style

    public init(style: Style) {
        // Save the style:
        self.style = style

        super.init(frame: .zero)

        // Configure the view:
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: FallbackViewModelView + StyledView

extension FallbackViewModelView: StyledView {
    public typealias Style = EmptyStyle
}

// MARK: FallbackViewModelView + ContentConfigurable

extension FallbackViewModelView: ContentConfigurable {
    public typealias Content = EmptyContent
}
