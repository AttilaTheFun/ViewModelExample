import ContentFoundation
import UIKit

open class ViewModelTableView: UITableView {
    // MARK: Properties

    private lazy var diffableDataSource = ViewModelTableViewDataSource(tableView: self)

    // MARK: Initialization

    public convenience init() {
        self.init(frame: .zero, style: .plain)
    }

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        // Configure the receiver:
        translatesAutoresizingMaskIntoConstraints = false

        // Force the instantiation of the diffable data source:
        _ = self.diffableDataSource
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ViewModelTableView + ContentConfigurable

extension ViewModelTableView: ContentConfigurable {
    public struct Content: Hashable {
        public init(sections: [ViewModelTableViewSection]) {
            self.sections = sections
        }

        public let sections: [ViewModelTableViewSection]
    }

    public func configure(for content: Content) {
        self.diffableDataSource.apply(sections: content.sections)
    }
}
