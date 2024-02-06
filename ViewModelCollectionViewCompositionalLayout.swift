import UIKit

/**
 Usage:

 let collectionView = UICollectionView()
 let dataSource: ViewModelCollectionViewDataSource

 init(...) {

    // Create the data source:
    self.dataSource = ViewModelCollectionViewDataSource(collectionView: self.collectionView)

    // Create the collection view layout:
    self.collectionView.collectionViewLayout = ViewModelCollectionViewCompositionalLayout(dataSource: self.dataSource)
 }
 */
public final class ViewModelCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    // MARK: Initialization

    public init(
        dataSource: ViewModelCollectionViewSectionProviding,
        configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
    ) {
        super.init(sectionProvider: { [weak dataSource] section, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let dataSource, section < dataSource.numberOfSections()
            else {
                return nil
            }

            let viewModelSection = dataSource.viewModelSection(at: section)
            return viewModelSection.layoutSectionProvider?(layoutEnvironment)
        }, configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        (collectionView?.bounds ?? newBounds) != newBounds
    }
}

public extension ViewModelCollectionViewCompositionalLayout {
    convenience init(
        collectionView: ViewModelCollectionView,
        configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
    ) {
        self.init(
            dataSource: collectionView.diffableDataSource,
            configuration: configuration
        )
    }
}

public extension NSCollectionLayoutSection {
    // TODO: Rework all callsites to use the method below.
    static func fullWidthEstimatedHeightLayoutSection(
        layoutEnvironment: NSCollectionLayoutEnvironment
    )
        -> NSCollectionLayoutSection {
        let provider = self.fullWidthEstimatedHeightLayoutSectionProvider()
        return provider(layoutEnvironment)
    }

    static func fullWidthEstimatedHeightLayoutSectionProvider(maximumWidth: CGFloat = 640)
        -> (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    {
        { (layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            // Check the size of the layout environment:
            let contentSize = layoutEnvironment.container.contentSize
            let contentWidth = contentSize.width
            let limitedWidth = min(maximumWidth, contentWidth)
            let additionalWidth = max(contentWidth - limitedWidth, 0)

            // Create the layout item:
            let size = NSCollectionLayoutSize(
                // widthDimension: .fractionalWidth(1)
                widthDimension: .absolute(limitedWidth),
                heightDimension: .estimated(320)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)

            // Create the layout group:
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

            // Create the layout section:
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(horizontal: additionalWidth / 2)

            return section
        }
    }
}
