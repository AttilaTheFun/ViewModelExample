import UIKit

public protocol ViewModelListViewDataSource: AnyObject {
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func viewModel(at indexPath: IndexPath) -> ViewModel
}
