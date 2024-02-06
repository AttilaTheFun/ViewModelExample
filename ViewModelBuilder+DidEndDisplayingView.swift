import Foundation

public extension CallableClosureKey {
    static let didEndDisplayingView = "DidEndDisplayingView"
}

public extension ViewModelBuilder {
    /**
     A closure called by the enclosing view when the view did end being displayed.
     */
    func withDidEndDisplayingView(_ didEndDisplayingView: CallableClosure<View>?) -> Self {
        withCallableClosure(didEndDisplayingView, for: CallableClosureKey.didEndDisplayingView)
    }
}
