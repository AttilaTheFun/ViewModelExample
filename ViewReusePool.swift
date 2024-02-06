import UIKit

/**
 The ViewReusePool is useful for pooling and reusing expensive views constructed with view models.
 */
public final class ViewReusePool {
    // MARK: Properties

    private var views = [ViewKey: UIView]()

    // MARK: Initialization

    public init() {}

    // MARK: Interface

    func enqueue(view: UIView, from viewModel: ViewModel) {
        self.views[viewModel.viewKey] = view
    }

    func dequeueView(for viewModel: ViewModel) -> UIView {
        assert(Thread.isMainThread, "Requires main thread")

        if let view = views[viewModel.viewKey] {
            self.views[viewModel.viewKey] = nil
            return view
        }

        return viewModel.createView()
    }
}
