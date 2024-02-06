import UIKit

public extension MetadataKey {
    static let separatorHidden = "SeparatorHidden"
}

public extension ViewModelBuilder {
    func withSeparatorHidden(_ separatorHidden: Bool) -> Self {
        withValue(separatorHidden, for: MetadataKey.separatorHidden)
    }
}

public extension ViewModel {
    var separatorHidden: Bool {
        typedValue(for: MetadataKey.separatorHidden) ?? false
    }
}
