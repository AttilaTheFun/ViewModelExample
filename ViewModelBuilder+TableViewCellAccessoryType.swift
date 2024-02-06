import UIKit

public extension MetadataKey {
    static let tableViewCellAccessoryType = "TableViewCellAccessoryType"
}

public extension ViewModelBuilder {
    /**
     A flag indicating whether the content should be flipped about its Y axis.
     */
    func withTableViewCellAccessoryType(_ accessoryType: UITableViewCell.AccessoryType) -> Self {
        withValue(accessoryType, for: MetadataKey.tableViewCellAccessoryType)
    }
}

public extension ViewModel {
    /**
     Retrieves the tableViewCellAccessoryType value from the view model's metadata dictionary.
     */
    var tableViewCellAccessoryType: UITableViewCell.AccessoryType {
        typedValue(for: MetadataKey.tableViewCellAccessoryType) ?? .none
    }
}
