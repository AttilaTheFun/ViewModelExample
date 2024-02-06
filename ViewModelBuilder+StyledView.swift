import ContentFoundation
import StyleFoundation

public extension ViewModelBuilder where View: ContentConfigurable & StyledView {
    convenience init(
        identity: String,
        viewSubtype: String,
        style: View.Style,
        content: View.Content
    ) {
        self.init(
            identity: identity,
            viewSubtype: viewSubtype,
            content: content,
            creator: { View(style: style) }
        )
    }
}

public extension ViewModelBuilder where View: ContentConfigurable & StyledView, View.Style: NamedStyle {
    convenience init(identity: String, viewSubtype: String? = nil, style: View.Style, content: View.Content) {
        let viewSubtype = viewSubtype ?? style.name
        self.init(
            identity: identity,
            viewSubtype: viewSubtype,
            style: style,
            content: content
        )
    }
}

public extension ViewModelBuilder where View: ContentConfigurable & StyledView, View.Style: StandardStyle {
    convenience init(identity: String, viewSubtype: String? = nil, content: View.Content) {
        self.init(
            identity: identity,
            viewSubtype: viewSubtype,
            style: .standard,
            content: content
        )
    }
}
