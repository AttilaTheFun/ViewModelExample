import DiffableDataSource
import UIKit

/**
 !!! WARNING !!!

 When adding fields to this structure, ensure you also add them to extension ViewModelTableViewSection: AnimatableSectionModelType
 */
public struct ViewModelTableViewSection: Hashable {
    public let identity: String

    public let indexTitle: String?

    public let headerTitle: String?
    public let header: ViewModel?

    public let items: [ViewModel]

    public let footerTitle: String?
    public let footer: ViewModel?

    public init(
        identity: String,
        indexTitle: String? = nil,
        headerTitle: String? = nil,
        header: ViewModel? = nil,
        items: [ViewModel],
        footerTitle: String? = nil,
        footer: ViewModel? = nil
    ) {
        self.identity = identity
        self.indexTitle = indexTitle
        self.headerTitle = headerTitle
        self.header = header
        self.items = items
        self.footerTitle = footerTitle
        self.footer = footer
    }
}

// MARK: ViewModelTableViewSection + Identifiable

extension ViewModelTableViewSection: Identifiable {
    public var id: String {
        self.identity
    }
}

// MARK: ViewModelTableViewSection + SectionType

extension ViewModelTableViewSection: SectionType {}
