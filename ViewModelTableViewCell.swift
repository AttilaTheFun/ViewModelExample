import AssociatedObjectFoundation
import ContentFoundation
import UIKit
import ViewFoundation

public final class ViewModelTableViewCell: UITableViewCell {
    // MARK: Subviews

    public let wrapperView = ViewModelWrapperView()

    // MARK: Properties

    public private(set) var content: Content?

    // MARK: Initialization

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Configure the receiver:
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView = ViewModelCellSelectedBackgroundView()
        clipsToBounds = false

        addContentSubview(self.wrapperView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelTableViewCell + ContentConfigurable

extension ViewModelTableViewCell: ContentConfigurable {
    public typealias Content = ViewModel

    public func configure(for content: ViewModel) {
        self.content = content
        self.wrapperView.configure(for: .init(viewModel: content))
        accessoryType = content.tableViewCellAccessoryType
    }
}

// MARK: ViewModelTableViewCell + DisplayableView

extension ViewModelTableViewCell: DisplayableView {
    public func willDisplay() {
        self.wrapperView.willDisplay()
    }

    public func didEndDisplaying() {
        self.wrapperView.didEndDisplaying()
    }
}

// MARK: ViewModelTableViewCell + HighlightableView

extension ViewModelTableViewCell: HighlightableView {
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.wrapperView.setHighlighted(highlighted, animated: animated)
    }
}

// MARK: ViewModelTableViewCell + Selection

public extension ViewModelTableViewCell {
    func didSelectView() {
        self.wrapperView.didSelectView()
    }
}

// MARK: UITableView + ViewModelTableViewCell

extension UITableView {
    private static var registeredCellReuseIdentifiersHandle: UInt8 = 0
    private static let registeredCellReuseIdentifiersKey =
        AssociatedObjectKey<Set<String>>(handle: &registeredCellReuseIdentifiersHandle)
    private var registeredCellReuseIdentifiers: Set<String> {
        get { get(UITableView.registeredCellReuseIdentifiersKey) ?? [] }
        set { set(newValue, forKey: UITableView.registeredCellReuseIdentifiersKey) }
    }

    public func dequeueReusableCell(for viewModel: ViewModel, at indexPath: IndexPath) -> ViewModelTableViewCell {
        // Register the cell if necessary:
        let reuseIdentifier = viewModel.viewKey.reuseIdentifier
        if !self.registeredCellReuseIdentifiers.contains(reuseIdentifier) {
            register(ViewModelTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            self.registeredCellReuseIdentifiers = self.registeredCellReuseIdentifiers.union(Set([reuseIdentifier]))
        }

        return self.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ViewModelTableViewCell
    }
}
