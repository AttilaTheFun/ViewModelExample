import AssociatedObjectFoundation
import Strain
import UIKit
import ViewFoundation

// MARK: ViewModelBuilder + AspectRatio

public extension MetadataKey {
    static let aspectRatio = "AspectRatio"
}

public extension UpdateClosureKey {
    static let aspectRatioUpdater = "AspectRatioUpdater"
}

public extension ViewModelBuilder {
    /**
     Adds an update closure to the receiver which gives the view an aspect ratio constraint matching the given value, or removes it if the value is zero.
     */
    func withAspectRatio(_ aspectRatio: CGFloat) -> Self {
        let aspectRatioUpdateClosure: UpdateClosure = { view in
            // Remove and release the previous constraint if necessary:
            if
                let aspectRatioConstraint = view.aspectRatioConstraint,
                !aspectRatioConstraint.multiplier.isApproximatelyEqual(to: aspectRatio)
            {
                aspectRatioConstraint.isActive = false
                view.aspectRatioConstraint = nil
            }

            // Create and add the new constraint if necessary:
            if view.aspectRatioConstraint == nil, aspectRatio != .zero {
                view.aspectRatioConstraint = view.constrain(aspectRatio: aspectRatio)
            }
        }

        return withValue(aspectRatio, for: MetadataKey.aspectRatio)
            .withUpdateClosure(aspectRatioUpdateClosure, for: UpdateClosureKey.aspectRatioUpdater)
    }
}

// MARK: ViewModel + AspectRatio

public extension ViewModel {
    /**
     Retrieves the aspect ratio the view is constrained to, or .zero if it's not constrained.
     */
    var aspectRatio: CGFloat {
        typedValue(for: MetadataKey.aspectRatio) ?? .zero
    }
}

// MARK: UIView + AspectRatio

private var aspectRatioConstraintHandle: UInt8 = 0
private let aspectRatioConstraintKey = AssociatedObjectKey<NSLayoutConstraint>(handle: &aspectRatioConstraintHandle)

private extension UIView {
    var aspectRatioConstraint: NSLayoutConstraint? {
        get {
            get(aspectRatioConstraintKey)
        }
        set {
            set(newValue, forKey: aspectRatioConstraintKey)
        }
    }
}
