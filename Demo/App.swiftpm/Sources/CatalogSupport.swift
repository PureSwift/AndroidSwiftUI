#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Type-erased catalog screen (a small AnyView shim usable as a navigation
/// destination while keeping the entry list homogeneous).
struct AnyCatalogScreen: View {
    private let content: AnyView
    init<V: View>(_ view: V) { self.content = AnyView(view) }
    var body: some View { content }
}

/// A titled example row shared by the playgrounds.
struct Example<Content: View>: View {
    let title: String
    let content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            content
            Divider()
        }
        .padding()
    }
}
