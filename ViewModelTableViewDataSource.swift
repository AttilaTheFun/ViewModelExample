import DiffableDataSource
import SwiftFoundation
import UIKit
import ViewFoundation

// MARK: ViewModelTableViewDataSource

public final class ViewModelTableViewDataSource: TableViewDiffableDataSource<ViewModelTableViewSection, ViewModel> {
    // MARK: Properties

    private var estimatedCellHeightCache = [IndexPath: CGFloat]()
    private var prefetchingViewModels = [IndexPath: ViewModel]()

    // MARK: Initialization

    public init(tableView: UITableView) {
        super.init(
            view: tableView,
            cellProvider: { tableView, indexPath, viewModel -> UITableViewCell? in
                tableView.dequeueReusableCell(for: viewModel, at: indexPath)
            },
            cellConfigurer: { _, _, viewModel, cell in
                guard let cell = cell as? ViewModelTableViewCell else { return }
                cell.configure(for: viewModel)
            }
        )

        // Set the default animation:
        defaultRowAnimation = .fade

        // Wire up the table view delegate:
        tableView.delegate = self
        tableView.prefetchDataSource = self
    }

    // MARK: Overrides

    override public func sectionIndexTitles(for _: UITableView) -> [String]? {
        sections.compactMap(\.indexTitle)
    }

    override public func tableView(
        _: UITableView,
        sectionForSectionIndexTitle _: String, at index: Int
    )
        -> Int {
        let sectionsWithTitles = sections.enumerated().compactMap { sectionIndex, section in
            section.indexTitle.map { (sectionIndex, $0) }
        }

        return sectionsWithTitles[index].0
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.headerTitle
    }

    override public func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = sections[section]
        return section.footerTitle
    }
}

// MARK: ViewModelListViewDataSource

extension ViewModelTableViewDataSource: ViewModelListViewDataSource {
    public func numberOfSections() -> Int {
        let snapshot = snapshot()
        return snapshot.numberOfSections
    }

    public func viewModelSection(at index: Int) -> ViewModelTableViewSection {
        let snapshot = snapshot()
        let sectionIdentifier = snapshot.sectionIdentifiers[index]
        return sectionIdentifier.value
    }

    public func numberOfItems(in section: Int) -> Int {
        let snapshot = snapshot()
        let sectionIdentifier = snapshot.sectionIdentifiers[section]
        return snapshot.numberOfItems(inSection: sectionIdentifier)
    }

    public func viewModel(at indexPath: IndexPath) -> ViewModel {
        let snapshot = snapshot()
        let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
        let itemIdentifiersInSection = snapshot.itemIdentifiers(inSection: sectionIdentifier)
        let itemIdentifier = itemIdentifiersInSection[indexPath.item]
        return itemIdentifier.value
    }
}

// MARK: ViewModelTableViewDataSource + UITableViewDelegate

extension ViewModelTableViewDataSource: UITableViewDelegate {
    // MARK: Header

    public func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let viewModelSection = sections[section]
        guard viewModelSection.header != nil
        else {
            return 0
        }

        return UITableView.automaticDimension
    }

    public func tableView(_: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let viewModelSection = sections[section]
        guard viewModelSection.header != nil
        else {
            return 0
        }

        return 48
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewModelSection = sections[section]
        guard let headerViewModel = viewModelSection.header
        else {
            return nil
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(for: headerViewModel)
        headerView.configure(for: headerViewModel)
        return headerView
    }

    // MARK: Footer

    public func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let viewModelSection = sections[section]
        guard viewModelSection.footer != nil
        else {
            return 0
        }

        return UITableView.automaticDimension
    }

    public func tableView(_: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let viewModelSection = sections[section]
        guard viewModelSection.header != nil
        else {
            return 0
        }

        return 48
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewModelSection = sections[section]
        guard let footerViewModel = viewModelSection.footer
        else {
            return nil
        }

        let footerView = tableView.dequeueReusableHeaderFooterView(for: footerViewModel)
        footerView.configure(for: footerViewModel)
        return footerView
    }

    // MARK: Cells

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cachedEstimatedHeight = estimatedCellHeightCache[indexPath] {
            return cachedEstimatedHeight
        }

        return tableView.estimatedRowHeight
    }

    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ViewModelTableViewCell
        else {
            return
        }

        cell.willDisplay()

        // Cache the height of the new cell:
        self.estimatedCellHeightCache[indexPath] = cell.bounds.height
    }

    public func tableView(
        _: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt _: IndexPath
    ) {
        guard let cell = cell as? ViewModelTableViewCell
        else {
            return
        }

        cell.didEndDisplaying()
    }

    // MARK: Selection

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ViewModelTableViewCell
        else {
            return
        }

        cell.didSelectView()
    }

    // MARK: Context Menu

    public func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? ViewModelTableViewCell,
            let viewModel = cell.content,
            let closureContextMenuInteractor = viewModel.closureContextMenuInteractor,
            let configuration = closureContextMenuInteractor.configurationForContextMenu?(point, cell.wrapperView)
        else
        {
            return nil
        }

        closureContextMenuInteractor.contextMenuView = cell.wrapperView
        configuration.closureContextMenuInteractor = closureContextMenuInteractor
        configuration.contextMenuView = cell.wrapperView
        return configuration
    }

    public func tableView(
        _: UITableView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    )
        -> UITargetedPreview? {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return nil
        }

        return closureContextMenuInteractor.previewForHighlightingContextMenu?(configuration)
    }

    public func tableView(
        _: UITableView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    )
        -> UITargetedPreview? {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return nil
        }

        return closureContextMenuInteractor.previewForDismissingContextMenu?(configuration)
    }

    public func tableView(
        _: UITableView,
        willDisplayContextMenu configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return
        }

        closureContextMenuInteractor.willDisplayContextMenu?(configuration, animator)
    }

    public func tableView(
        _: UITableView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return
        }

        closureContextMenuInteractor.willEndContextMenu?(configuration, animator)
    }

    public func tableView(
        _: UITableView,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return
        }

        closureContextMenuInteractor.willPerformActionForContextMenu?(configuration, animator)
    }
}

// MARK: ViewModelTableViewDataSource + UITableViewDataSourcePrefetching

extension ViewModelTableViewDataSource: UITableViewDataSourcePrefetching {
    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //
        // !!! WARNING !!!
        //
        // When cancelPrefetchingForItemsAt is called, the index paths provided to prefetchItemsAt
        // may not be present in the data source anymore. They are index paths that were passed to prefetchRowsAt.
        //
        // As such, we can't query the current sections for the view models.
        // Rather, we must maintain a map of prefetching index paths to view models.
        //
        for indexPath in indexPaths {
            // Extract the view model:
            let viewModel = viewModel(at: indexPath)

            // Check if the view model has a prefetcher (and continue if not).
            guard let prefetcher = viewModel.prefetcher
            else {
                continue
            }

            // Begin prefetching:
            prefetcher.prefetch()

            // Store the view model in the prefetching map:
            self.prefetchingViewModels[indexPath] = viewModel
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        //
        // !!! WARNING !!!
        //
        // When cancelPrefetchingForItemsAt is called, the index paths provided to prefetchItemsAt
        // may not be present in the data source anymore. They are index paths that were passed to prefetchRowsAt.
        //
        // As such, we can't query the current sections for the view models.
        // Rather, we must maintain a map of prefetching index paths to view models.
        //
        for indexPath in indexPaths {
            // Extract the view model or continue if it's not prefetching:
            guard let prefetchingViewModel = prefetchingViewModels[indexPath]
            else {
                continue
            }

            // Stop prefetching:
            prefetchingViewModel.prefetcher?.cancelPrefetching()

            // Clear the view model out of the map.
            self.prefetchingViewModels[indexPath] = nil
        }
    }
}
