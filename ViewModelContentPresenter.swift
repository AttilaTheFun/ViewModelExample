// MARK: ViewModelStackViewContentPresenter

public typealias ViewModelStackViewContentPresenter<State: Equatable> =
    DefaultContentPresenter<State, [ViewModel]>

// MARK: ViewModelTableViewContentPresenter

public struct ViewModelTableViewContent: Hashable {
    public init(
        headerViewModel: ViewModel? = nil,
        sections: [ViewModelTableViewSection],
        footerViewModel: ViewModel? = nil
    ) {
        self.headerViewModel = headerViewModel
        self.sections = sections
        self.footerViewModel = footerViewModel
    }

    public let headerViewModel: ViewModel?
    public let sections: [ViewModelTableViewSection]
    public let footerViewModel: ViewModel?
}

public typealias ViewModelTableViewContentPresenter<State: Equatable> =
    DefaultContentPresenter<State, ViewModelTableViewContent>

// MARK: ViewModelCollectionViewContentPresenter

public typealias ViewModelCollectionViewContentPresenter<State: Equatable> =
    DefaultContentPresenter<State, [ViewModelCollectionViewSection]>
