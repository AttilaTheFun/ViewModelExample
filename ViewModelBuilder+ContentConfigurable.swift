import ContentFoundation
import UIKit

private struct ContentWrapper: Hashable {
    let content: AnyHashable
    let additionalContent: AnyHashable?
}

public extension UpdateClosureKey {
    static let contentConfigurer = "ContentConfigurer"
}

public extension ViewModelBuilder where View: ContentConfigurable {
    convenience init(
        identity: String,
        viewSubtype: String,
        content: View.Content,
        additionalContent: AnyHashable? = nil,
        updateClosures: [String: UpdateClosure<View>] = [:],
        metadata: [String: Any] = [:],
        creator: @escaping () -> View
    ) {
        // Create the content configurer closure:
        var newUpdateClosures = updateClosures
        newUpdateClosures[UpdateClosureKey.contentConfigurer] = { view in
            view.configure(for: content)
        }

        let wrappedContent = ContentWrapper(content: content, additionalContent: additionalContent)
        self.init(
            identity: identity,
            viewSubtype: viewSubtype,
            content: AnyHashable(wrappedContent),
            updateClosures: newUpdateClosures,
            metadata: metadata,
            creator: creator
        )
    }
}
