#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct LabelPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Label") {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Favorites", systemImage: "star.fill")
                        Label("Delete", systemImage: "trash")
                        Label("Mail", systemImage: "envelope")
                    }
                }
                Example("labelStyle(.titleOnly)") {
                    Label("Only the title", systemImage: "star.fill")
                        .labelStyle(.titleOnly)
                }
                Example("labelStyle(.iconOnly)") {
                    Label("Hidden title", systemImage: "star.fill")
                        .labelStyle(.iconOnly)
                }
                Example("Inherited by a container") {
                    // one style styles both labels
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Inherited one", systemImage: "heart.fill")
                        Label("Inherited two", systemImage: "heart.fill")
                    }
                    .labelStyle(.iconOnly)
                }
            }
        }
        .navigationTitle("Label")
    }
}
