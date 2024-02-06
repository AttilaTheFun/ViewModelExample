import AssociatedObjectFoundation
import ContentFoundation
import UIKit
import ViewFoundation

public final class ViewModelCollectionViewCell: UICollectionViewCell {
    // MARK: Subviews & Constraints

    public private(set) var viewModelView: ViewModelView?

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)

        // Configure the receiver:
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView = ViewModelCellSelectedBackgroundView()
        clipsToBounds = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    override public var isHighlighted: Bool {
        didSet {
            setHighlighted(self.isHighlighted, animated: true)
        }
    }
}

// MARK: ViewModelCollectionViewCell + ContentConfigurable

extension ViewModelCollectionViewCell: ContentConfigurable {
    public typealias Content = ViewModel

    public func configure(for content: ViewModel) {
        // Update or create the view model view:
        if let viewModelView {
            viewModelView.configure(forViewModel: content)
        } else {
            let viewModelView = content.viewModelView()
            self.viewModelView = viewModelView
            addContentSubview(viewModelView)
        }

        // Save the new content:
        viewModel = content
    }
}

// MARK: ViewModelCollectionViewCell + DisplayableView

extension ViewModelCollectionViewCell: DisplayableView {
    public func willDisplay() {
        self.viewModelView?.handleWillDisplay()
    }

    public func didEndDisplaying() {
        self.viewModelView?.handleDidEndDisplaying()
    }
}

// MARK: ViewModelCollectionViewCell + SelectableView

extension ViewModelCollectionViewCell: SelectableView {
    public func didSelectView() {
        self.viewModelView?.handleDidSelectView()
    }
}

// MARK: ViewModelCollectionViewCell + HighlightableView

extension ViewModelCollectionViewCell: HighlightableView {
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.viewModelView?.handleSetHighlighted(highlighted, animated: animated)
    }
}

// MARK: UICollectionView + ViewModelCollectionViewCell

extension UICollectionView {
    private static var registeredCellReuseIdentifiersHandle: UInt8 = 0
    private static let registeredCellReuseIdentifiersKey =
        AssociatedObjectKey<Set<String>>(handle: &registeredCellReuseIdentifiersHandle)
    private var registeredCellReuseIdentifiers: Set<String> {
        get { get(UICollectionView.registeredCellReuseIdentifiersKey) ?? [] }
        set { set(newValue, forKey: UICollectionView.registeredCellReuseIdentifiersKey) }
    }

    public func dequeueReusableCell(for viewModel: ViewModel, at indexPath: IndexPath) -> ViewModelCollectionViewCell {
        // Register the cell if necessary:
        let reuseIdentifier = viewModel.viewKey.reuseIdentifier
        if !self.registeredCellReuseIdentifiers.contains(reuseIdentifier) {
            register(ViewModelCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            self.registeredCellReuseIdentifiers = self.registeredCellReuseIdentifiers.union(Set([reuseIdentifier]))
        }

        return self.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! ViewModelCollectionViewCell
    }
}
