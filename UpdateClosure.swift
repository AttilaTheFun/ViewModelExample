import UIKit

// MARK: UpdateClosure

public typealias UpdateClosure<View> = (View) -> Void where View: UIView

// MARK: UpdateClosureKey

/**
 A namespace for update closure dictionary keys.
 */
public enum UpdateClosureKey {}
