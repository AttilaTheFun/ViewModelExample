import Foundation
import UIKit

public extension CallableClosureKey {
    static let didSelectView = "DidSelectView"
}

public extension ViewModelBuilder {
    /**
     A closure called by the enclosing table view / collection view when the view is selected.
     */
    func withDidSelectView(_ didSelectView: CallableClosure<View>?) -> Self {
        withCallableClosure(didSelectView, for: CallableClosureKey.didSelectView)
    }
}

public extension ViewModel {
    var didSelectView: ((UIView) -> Void)? {
        callableClosure(for: CallableClosureKey.didSelectView)
    }
}
