import UIKit

// MARK: CallableClosure

public typealias CallableClosure<View> = (View) -> Void where View: UIView

// MARK: CallableClosureKey

/**
 A namespace for Callable closure dictionary keys.
 */
public enum CallableClosureKey {}
