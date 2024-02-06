import AssociatedObjectFoundation
import ContentFoundation
import UIKit
import ViewFoundation

public final class ViewModelCollectionReusableView: UICollectionReusableView {
    // MARK: Subviews & Constraints

    private let wrapperView = ViewModelWrapperView()

    // MARK: Content

    private var content: Content?

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)

        // Configure the receiver:
        clipsToBounds = false

        // Add the wrapper view as a subview:
        addSubview(self.wrapperView)

        // Constrain the wrapper view to the receiver:
        self.wrapperView.constrain(to: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelCollectionReusableView + ContentConfigurable

extension ViewModelCollectionReusableView: ContentConfigurable {
    public typealias Content = ViewModel

    public func configure(for content: ViewModel) {
        self.content = content
        self.wrapperView.configure(for: .init(viewModel: content))
    }
}

// MARK: UICollectionView + ViewModelCollectionReusableView

extension UICollectionView {
    private static var registeredReuseIdentifiersForKindHandle: UInt8 = 0
    private static let registeredReuseIdentifiersForKindKey =
        AssociatedObjectKey<[String: Set<String>]>(handle: &registeredReuseIdentifiersForKindHandle)
    private var registeredReuseIdentifiersForKind: [String: Set<String>] {
        get { get(UICollectionView.registeredReuseIdentifiersForKindKey) ?? [:] }
        set { set(newValue, forKey: UICollectionView.registeredReuseIdentifiersForKindKey) }
    }

    public func dequeueReusableSupplementaryView(
        ofKind kind: String,
        for viewModel: ViewModel,
        at indexPath: IndexPath
    ) -> ViewModelCollectionReusableView {
        // Register the cell if necessary:
        let reuseIdentifier = viewModel.viewKey.reuseIdentifier
        var registeredReuseIdentifiers = self.registeredReuseIdentifiersForKind[kind, default: []]
        if !registeredReuseIdentifiers.contains(reuseIdentifier) {
            register(
                ViewModelCollectionReusableView.self,
                forSupplementaryViewOfKind: kind,
                withReuseIdentifier: reuseIdentifier
            )

            registeredReuseIdentifiers.insert(reuseIdentifier)
            self.registeredReuseIdentifiersForKind[kind] = registeredReuseIdentifiers
        }

        return self.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: viewModel.viewKey.reuseIdentifier,
            for: indexPath
        ) as! ViewModelCollectionReusableView
    }
}
