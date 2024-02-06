import UIKit

public struct ViewKey {
    /// The type of the view.
    /// Used in combination with the view subtype when considering a view for reuse and in hashable calculations.
    public let viewType: UIView.Type

    /// The subtype of the view (e.g. for a view with multiple styles).
    /// Used in combination with the view type when considering a view for reuse in hashable calculations.
    public let viewSubtype: String

    /**
     Creates a reuse identifier for instances of the built view.
     */
    public var reuseIdentifier: String {
        String(describing: self.viewType) + self.viewSubtype
    }
}

extension ViewKey: Hashable {
    public static func == (lhs: ViewKey, rhs: ViewKey) -> Bool {
        ObjectIdentifier(lhs.viewType) == ObjectIdentifier(rhs.viewType)
            && lhs.viewSubtype == rhs.viewSubtype
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self.viewType).hash(into: &hasher)
        self.viewSubtype.hash(into: &hasher)
    }
}
