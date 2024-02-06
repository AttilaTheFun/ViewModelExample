import Combine
import Strain
import UIKit
import ViewFoundation

open class ViewModelStackViewController<Dependencies, Store>: UIViewController where Store: StateStore {
    // MARK: Subviews & Constraints

    public let scrollView: UIScrollView
    private let stackView: ViewModelStackView
    private var heightConstraint = NSLayoutConstraint()

    // MARK: Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: Injected Dependencies

    public let dependencies: Dependencies
    public let store: Store
    public let presenter: Presenter
    public typealias Presenter = ViewModelStackViewContentPresenter<Store.State>

    // MARK: Initialization

    public init(
        dependencies: Dependencies,
        store: Store,
        presenter: Presenter,
        style: ViewModelStackView.Style,
        createScrollView: () -> (UIScrollView) = { UIScrollView(frame: .zero) }
    ) {
        // Save the injected dependencies:
        self.dependencies = dependencies
        self.store = store
        self.presenter = presenter

        // Create the tableview:
        self.scrollView = createScrollView()
        self.stackView = ViewModelStackView(style: style)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Configure the views:
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.frame = view.bounds
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        // Create the view hierarchy:
        self.scrollView.addSubview(self.stackView)
        view.addSubview(self.scrollView)

        // Layout the views:
        self.stackView.constrain(to: self.scrollView)
        self.stackView.widthAnchor.constrain(equalTo: self.scrollView.widthAnchor)
        self.scrollView.constrain(to: view)
        self.heightConstraint = view.constrain(height: 0)
        self.heightConstraint.priority = .defaultHigh

        // Observe the data source:
        let viewModels = self.presenter.present(state: self.store.state)
        self.stackView.configure(for: .init(viewModels: viewModels))
        self.store.statePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self else { return }
                let viewModels = presenter.present(state: state)
                stackView.configure(for: .init(viewModels: viewModels))
            })
            .store(in: &self.subscriptions)
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = self.scrollView.contentSize.height
        if height != self.heightConstraint.constant {
            self.heightConstraint.constant = height
        }
    }
}

extension ViewModelStackViewController: ScrollViewProviding {
    public var providedScrollView: UIScrollView {
        self.scrollView
    }
}
