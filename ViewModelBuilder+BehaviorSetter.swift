import Foundation

public extension UpdateClosureKey {
    static let behaviorSetter = "BehaviorSetter"
}

public extension ViewModelBuilder {
    /**
     A closure called after the view is updated which can be used as an opportunity to wire up delegates, closures and actions.
     */
    func withBehaviorSetter(_ behaviorSetter: UpdateClosure<View>?) -> Self {
        withUpdateClosure(behaviorSetter, for: UpdateClosureKey.behaviorSetter)
    }
}
