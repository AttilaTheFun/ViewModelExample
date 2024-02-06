import UIKit

public extension MetadataKey {
    static let collectionLayoutItem = "CollectionLayoutItem"
}

public extension ViewModelBuilder {
    /**
     Attaches a collection layout item to the view model builder.
     */
    func withCollectionLayoutItem(_ collectionLayoutItem: NSCollectionLayoutItem?) -> Self {
        withValue(collectionLayoutItem, for: MetadataKey.collectionLayoutItem)
    }
}

public extension ViewModel {
    /**
     Retrieves the collection layout item (if set).
     */
    var collectionLayoutItem: NSCollectionLayoutItem? {
        typedValue(for: MetadataKey.collectionLayoutItem)
    }
}
