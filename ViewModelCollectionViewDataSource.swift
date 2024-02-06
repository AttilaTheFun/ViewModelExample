import DiffableDataSource
import SwiftFoundation
import UIKit

public protocol ViewModelCollectionViewSectionProviding: AnyObject {
    func numberOfSections() -> Int
    func viewModelSection(at index: Int) -> ViewModelCollectionViewSection
}

// MARK: ViewModelCollectionViewDataSource

public typealias ParentViewModelCollectionViewDataSource =
    CollectionViewDiffableDataSource<ViewModelCollectionViewSection, ViewModel>

public final class ViewModelCollectionViewDataSource: ParentViewModelCollectionViewDataSource {
    // MARK: Properties

    private var prefetchingViewModels = [IndexPath: ViewModel]()

    // MARK: Initialization

    public init(collectionView: UICollectionView) {
        super.init(
            view: collectionView,
            cellProvider: { collectionView, indexPath, viewModel -> UICollectionViewCell? in
                collectionView.dequeueReusableCell(for: viewModel, at: indexPath)
            },
            cellConfigurer: { _, _, viewModel, cell in
                guard let cell = cell as? ViewModelCollectionViewCell else { return }
                cell.configure(for: viewModel)
            }
        )

        // Wire up the collection view delegate:
        collectionView.delegate = self
        collectionView.prefetchDataSource = self

        // Create the supplementary view provider:
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return UICollectionReusableView() }

            // Retrieve the view model section and supplementary view model from the data source:
            let viewModelSection = viewModelSection(at: indexPath.section)
            guard let viewModel = viewModelSection.supplementaryViews[kind] else { return UICollectionReusableView() }

            // Dequeue the supplementary view for the view model:
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                for: viewModel,
                at: indexPath
            )

            // Configure the view for the view model:
            supplementaryView.configure(for: viewModel)

            return supplementaryView
        }
    }
}

// MARK: ViewModelCollectionViewDataSource + ViewModelCollectionViewSectionProviding

extension ViewModelCollectionViewDataSource: ViewModelCollectionViewSectionProviding {
    public func numberOfSections() -> Int {
        let snapshot = snapshot()
        return snapshot.numberOfSections
    }

    public func viewModelSection(at index: Int) -> ViewModelCollectionViewSection {
        let snapshot = snapshot()
        let sectionIdentifier = snapshot.sectionIdentifiers[index]
        return sectionIdentifier.value
    }
}

// MARK: ViewModelCollectionViewDataSource + ViewModelListViewDataSource

extension ViewModelCollectionViewDataSource: ViewModelListViewDataSource {
    public func numberOfItems(in sectionIndex: Int) -> Int {
        let section = self.viewModelSection(at: sectionIndex)
        return section.items.count
    }

    public func viewModel(at indexPath: IndexPath) -> ViewModel {
        let section = self.viewModelSection(at: indexPath.section)
        return section.items[indexPath.row]
    }
}

// MARK: ViewModelCollectionViewDataSource + UICollectionViewDelegate

extension ViewModelCollectionViewDataSource: UICollectionViewDelegate {
    // MARK: Life Cycle

    public func collectionView(
        _: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt _: IndexPath
    ) {
        guard let cell = cell as? ViewModelCollectionViewCell
        else {
            return
        }

        cell.willDisplay()
    }

    public func collectionView(
        _: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt _: IndexPath
    ) {
        guard let cell = cell as? ViewModelCollectionViewCell
        else {
            return
        }

        cell.didEndDisplaying()
    }

    // MARK: Selection

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ViewModelCollectionViewCell
        else {
            return
        }

        cell.didSelectView()
    }

    // MARK: Context Menu

    public func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? ViewModelCollectionViewCell,
            let viewModelView = cell.viewModelView,
            let closureContextMenuInteractor = cell.viewModel.closureContextMenuInteractor,
            let configuration = closureContextMenuInteractor.configurationForContextMenu?(point, viewModelView)
        else
        {
            return nil
        }

        closureContextMenuInteractor.contextMenuView = viewModelView
        configuration.closureContextMenuInteractor = closureContextMenuInteractor
        configuration.contextMenuView = viewModelView
        return configuration
    }

    public func collectionView(
        _: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    )
        -> UITargetedPreview? {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return nil
        }

        return closureContextMenuInteractor.previewForHighlightingContextMenu?(configuration)
    }

    public func collectionView(
        _: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    )
        -> UITargetedPreview? {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return nil
        }

        return closureContextMenuInteractor.previewForDismissingContextMenu?(configuration)
    }

    public func collectionView(
        _: UICollectionView,
        willDisplayContextMenu configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return
        }

        closureContextMenuInteractor.willDisplayContextMenu?(configuration, animator)
    }

    public func collectionView(
        _: UICollectionView,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        guard let closureContextMenuInteractor = configuration.closureContextMenuInteractor
        else {
            return
        }

        closureContextMenuInteractor.willEndContextMenu?(configuration, animator)
    }

    public func collectionView(
        _: UICollectionView,
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

// MARK: ViewModelCollectionViewDataSource + UICollectionViewDataSourcePrefetching

extension ViewModelCollectionViewDataSource: UICollectionViewDataSourcePrefetching {
    public func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
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

    public func collectionView(
        _: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
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
