import DiffableDataSource
import UIKit

public typealias LayoutSectionProvider = (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

/**
 !!! WARNING !!!

 When adding fields to this structure, ensure you also add them to the extension ViewModelCollectionViewSection: AnimatableSectionModelType
 */
public struct ViewModelCollectionViewSection {
    public let identity: String

    /**
     These titles are returned from the indexTitles collection view data source method if supplied.
     */
    public let indexTitle: String?

    /**
     If using UICollectionViewCompositionalLayout, use this field to supply the collection layout section corresponding to this collection view section.
     This value is excluded from equatable / hashable calculations.
     */
    public let layoutSectionProvider: LayoutSectionProvider?

    /**
     The view models for the items in the section.
     */
    public let items: [ViewModel]

    /**
     The supplementary views for the section.

     These can be custom views like decorations, or standard section header / footer views using the keys:
     - UICollectionView.elementKindSectionHeader
     - UICollectionView.elementKindSectionFooter
     */
    public let supplementaryViews: [String: ViewModel]

    public init(
        identity: String,
        indexTitle: String? = nil,
        layoutSectionProvider: LayoutSectionProvider? = nil,
        items: [ViewModel],
        supplementaryViews: [String: ViewModel] = [:]
    ) {
        self.identity = identity
        self.indexTitle = indexTitle
        self.layoutSectionProvider = layoutSectionProvider
        self.items = items
        self.supplementaryViews = supplementaryViews
    }
}

// MARK: ViewModelCollectionViewSection + Hashable

extension ViewModelCollectionViewSection: Hashable {
    public static func == (lhs: ViewModelCollectionViewSection, rhs: ViewModelCollectionViewSection) -> Bool {
        lhs.identity == rhs.identity
            && lhs.indexTitle == rhs.indexTitle
            && lhs.items == rhs.items
            && lhs.supplementaryViews == rhs.supplementaryViews
    }

    public func hash(into hasher: inout Hasher) {
        self.identity.hash(into: &hasher)
        self.indexTitle.hash(into: &hasher)
        self.items.hash(into: &hasher)
        self.supplementaryViews.hash(into: &hasher)
    }
}

// MARK: ViewModelCollectionViewSection + Identifiable

extension ViewModelCollectionViewSection: Identifiable {
    public var id: String {
        self.identity
    }
}

// MARK: ViewModelCollectionViewSection + SectionType

extension ViewModelCollectionViewSection: SectionType {}
