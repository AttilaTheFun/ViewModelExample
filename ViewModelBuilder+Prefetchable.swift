import Foundation
import SwiftFoundation

public extension MetadataKey {
    static let prefetcher = "Prefetcher"
}

public extension ViewModelBuilder {
    /**
     Attaches a prefetcher to the view model builder.
     */
    func withPrefetcher(_ prefetcher: Prefetchable?) -> Self {
        withValue(prefetcher, for: MetadataKey.prefetcher)
    }
}

public extension ViewModel {
    /**
     Retrieves the type-erased prefetcher (if any) from the view model's metadata dictionary.
     */
    var prefetcher: Prefetchable? {
        typedValue(for: MetadataKey.prefetcher)
    }
}
