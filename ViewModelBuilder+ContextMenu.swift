import UIKit
import ViewFoundation

public extension MetadataKey {
    static let closureContextMenuInteractor = "ClosureContextMenuInteractor"
}

public extension ViewModelBuilder {
    func withClosureContextMenuInteractor(
        _ closureContextMenuInteractor: ClosureContextMenuInteractor?
    )
        -> Self {
        withValue(closureContextMenuInteractor, for: MetadataKey.closureContextMenuInteractor)
    }
}

public extension ViewModel {
    var closureContextMenuInteractor: ClosureContextMenuInteractor? {
        typedValue(for: MetadataKey.closureContextMenuInteractor)
    }
}
