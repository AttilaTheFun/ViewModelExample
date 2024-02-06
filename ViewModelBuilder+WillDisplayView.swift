import Foundation

public extension CallableClosureKey {
    static let willDisplayView = "WillDisplayView"
}

public extension ViewModelBuilder {
    /**
     A closure called by the enclosing view when the view is about to be displayed.
     */
    func withWillDisplayView(_ willDisplayView: CallableClosure<View>?) -> Self {
        withCallableClosure(willDisplayView, for: CallableClosureKey.willDisplayView)
    }
}
