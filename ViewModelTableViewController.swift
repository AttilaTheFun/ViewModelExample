import Combine
import UIKit
import ViewFoundation

open class ViewModelTableViewController<Dependencies, Store>: UIViewController where Store: StateStore {
    // MARK: Subviews

    public let tableView: UITableView

    // MARK: Properties

    private lazy var dataSource = ViewModelTableViewDataSource(tableView: self.tableView)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: Injected Dependencies

    public let dependencies: Dependencies
    public let store: Store
    public let presenter: Presenter
    public typealias Presenter = ViewModelTableViewContentPresenter<Store.State>

    // MARK: Initialization

    public init(
        dependencies: Dependencies,
        store: Store,
        presenter: Presenter,
        createTableView: () -> (UITableView) = { UITableView(frame: .zero) }
    ) {
        // Save the injected dependencies:
        self.dependencies = dependencies
        self.store = store
        self.presenter = presenter

        // Create the tableview:
        self.tableView = createTableView()

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
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.frame = view.bounds

        // Create the view hierarchy:
        view.addSubview(self.tableView)

        // Layout the views:
        self.tableView.constrain(to: view)

        // Present the initial content:
        let content = self.presenter.present(state: self.store.state)

        // Configure the views for the initial content:
        self.configureTableHeaderView(viewModel: content.headerViewModel)
        self.dataSource.apply(sections: content.sections)
        self.configureTableFooterView(viewModel: content.footerViewModel)

        // Observe the data source:
        self.store.statePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self else { return }

                // Present the new content:
                let content = presenter.present(state: state)

                // Configure the views for the new content:
                configureTableHeaderView(viewModel: content.headerViewModel)
                if content.sections != dataSource.sections {
                    dataSource.apply(sections: content.sections)
                }

                configureTableFooterView(viewModel: content.footerViewModel)
            })
            .store(in: &self.subscriptions)
    }

    // MARK: Private

    private func configureTableHeaderView(viewModel: ViewModel?) {
        guard let viewModel
        else {
            // Remove the table header view:
            self.tableView.removeTableHeaderView()

            return
        }

        // Extract or create the header wrapper view:
        let headerWrapperView: ViewModelWrapperView = if let wrapperView = tableView
            .tableHeaderView as? ViewModelWrapperView {
            wrapperView
        } else {
            ViewModelWrapperView()
        }

        // Configure the header wrapper view:
        headerWrapperView.configure(for: .init(viewModel: viewModel))

        // Set and/or layout the header wrapper view:
        if self.tableView.tableHeaderView == nil {
            self.tableView.setAndLayoutTableHeaderView(headerView: headerWrapperView)
        } else {
            self.tableView.updateHeaderViewFrame()
        }
    }

    private func configureTableFooterView(viewModel: ViewModel?) {
        guard let viewModel
        else {
            // Remove the table footer view:
            self.tableView.removeTableFooterView()

            return
        }

        // Extract or create the footer wrapper view:
        let footerWrapperView: ViewModelWrapperView = if let wrapperView = tableView
            .tableFooterView as? ViewModelWrapperView {
            wrapperView
        } else {
            ViewModelWrapperView()
        }

        // Configure the footer wrapper view:
        footerWrapperView.configure(for: .init(viewModel: viewModel))

        // Set and/or layout the footer wrapper view:
        if self.tableView.tableFooterView == nil {
            self.tableView.setAndLayoutTableFooterView(footerView: footerWrapperView)
        } else {
            self.tableView.updateFooterViewFrame()
        }
    }
}

extension ViewModelTableViewController: ScrollViewProviding {
    public var providedScrollView: UIScrollView {
        self.tableView
    }
}
