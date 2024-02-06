import AssociatedObjectFoundation
import ContentFoundation
import UIKit
import ViewFoundation

// MARK: ViewModelTableViewHeaderFooterView

public final class ViewModelTableViewHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: Subviews

    private let wrapperView = ViewModelWrapperView()

    // MARK: Initialization

    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        // Configure the receiver:
        clipsToBounds = false
        var backgroundConfiguration = UIBackgroundConfiguration.listPlainHeaderFooter()
        backgroundConfiguration.backgroundColor = .clear
        self.backgroundConfiguration = backgroundConfiguration

        addContentSubview(self.wrapperView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    /**
     !!! HACK !!!

     This works around a known UIKit bug with tableview header sizing.
     */
    override public var frame: CGRect {
        get {
            super.frame
        }
        set {
            if newValue.width == 0 { return }
            super.frame = newValue
        }
    }
}

// MARK: ViewModelTableViewHeaderFooterView + ContentConfigurable

extension ViewModelTableViewHeaderFooterView: ContentConfigurable {
    public typealias Content = ViewModel

    public func configure(for content: ViewModel) {
        self.wrapperView.configure(for: .init(viewModel: content))
    }
}

// MARK: UITableView + ViewModelTableViewHeaderFooterView

extension UITableView {
    private static var registeredHeaderFooterReuseIdentifiersHandle: UInt8 = 0
    private static let registeredHeaderFooterReuseIdentifiersKey =
        AssociatedObjectKey<Set<String>>(handle: &registeredHeaderFooterReuseIdentifiersHandle)
    private var registeredHeaderFooterReuseIdentifiers: Set<String> {
        get { get(UITableView.registeredHeaderFooterReuseIdentifiersKey) ?? [] }
        set { set(newValue, forKey: UITableView.registeredHeaderFooterReuseIdentifiersKey) }
    }

    public func dequeueReusableHeaderFooterView(for viewModel: ViewModel) -> ViewModelTableViewHeaderFooterView {
        // Register the view if necessary:
        let reuseIdentifier = viewModel.viewKey.reuseIdentifier
        if !self.registeredHeaderFooterReuseIdentifiers.contains(reuseIdentifier) {
            register(ViewModelTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            self.registeredHeaderFooterReuseIdentifiers = self.registeredHeaderFooterReuseIdentifiers
                .union(Set([reuseIdentifier]))
        }

        return self.dequeueReusableHeaderFooterView(
            withIdentifier: viewModel.viewKey.reuseIdentifier
        ) as! ViewModelTableViewHeaderFooterView
    }
}
