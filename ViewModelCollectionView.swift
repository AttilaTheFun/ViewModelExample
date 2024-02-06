import ContentFoundation
import UIKit

open class ViewModelCollectionView: UICollectionView {
    // MARK: Properties

    public private(set) lazy var diffableDataSource = ViewModelCollectionViewDataSource(collectionView: self)

    // MARK: Initialization

    public convenience init() {
        self.init(frame: .zero, collectionViewLayout: .init())
    }

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        // Configure the receiver:
        translatesAutoresizingMaskIntoConstraints = false

        // Force the instantiation of the diffable data source:
        _ = self.diffableDataSource
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelCollectionView + ContentConfigurable

extension ViewModelCollectionView: ContentConfigurable {
    public struct Content: Hashable {
        public init(sections: [ViewModelCollectionViewSection]) {
            self.sections = sections
        }

        public let sections: [ViewModelCollectionViewSection]
    }

    public func configure(for content: Content) {
        self.diffableDataSource.apply(sections: content.sections)
    }
}
