import Combine
import UIKit
import ViewFoundation

open class ViewModelCollectionViewController<Dependencies, Store>: UIViewController where Store: StateStore {
    // MARK: Subviews

    public let collectionView: UICollectionView

    // MARK: Properties

    private lazy var dataSource = ViewModelCollectionViewDataSource(collectionView: self.collectionView)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: Injected Dependencies

    public let dependencies: Dependencies
    public let store: Store
    public let presenter: Presenter
    public typealias Presenter = ViewModelCollectionViewContentPresenter<Store.State>

    // MARK: Initialization

    public init(
        dependencies: Dependencies,
        store: Store,
        presenter: Presenter,
        createCollectionView: () -> (UICollectionView) = { UICollectionView(frame: .zero) },
        updateCollectionViewLayout: (UICollectionView, ViewModelCollectionViewDataSource) -> Void = { _, _ in }
    ) {
        // Save the injected dependencies:
        self.dependencies = dependencies
        self.store = store
        self.presenter = presenter

        // Create the tableview:
        self.collectionView = createCollectionView()

        super.init(nibName: nil, bundle: nil)

        // Update the collection view layout if necessary:
        updateCollectionViewLayout(self.collectionView, self.dataSource)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Configure the views:
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.frame = view.bounds

        // Create the view hierarchy:
        view.addSubview(self.collectionView)

        // Layout the views:
        self.collectionView.constrain(to: view)

        // Observe the data source:
        let sections = self.presenter.present(state: self.store.state)
        self.dataSource.apply(sections: sections)
        self.store.statePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self else { return }
                let sections = presenter.present(state: state)
                dataSource.apply(sections: sections)
            })
            .store(in: &self.subscriptions)
    }
}

extension ViewModelCollectionViewController: ScrollViewProviding {
    public var providedScrollView: UIScrollView {
        self.collectionView
    }
}
