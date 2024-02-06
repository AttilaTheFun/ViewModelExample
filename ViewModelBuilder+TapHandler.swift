import ClosureFoundation
import UIKit

// MARK: Selection Handler

public extension ViewModelBuilder where View: UIButton {
    /**
     A wires up a tap handler to the button when it is built.
     */
    func withTapHandler(_ tapHandler: UpdateClosure<View>?) -> Self {
        guard let tapHandler
        else {
            return withUpdateClosure(nil, for: UpdateClosureKey.tapHandler)
        }
        return withUpdateClosure({ view in
            view.addAction(for: .touchUpInside) { control in
                guard let button = control as? View else { return }
                tapHandler(button)
            }
        }, for: UpdateClosureKey.tapHandler)
    }
}

public extension UpdateClosureKey {
    static let tapHandler = "TapHandler"
}
