#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct ContextMenuPlayground: View {

    @State private var status = "Long-press a row"
    @State private var pinned = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Long-press for a menu") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Project Alpha")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .contextMenu {
                                Button("Rename") { status = "Renamed Alpha" }
                                Button("Duplicate") { status = "Duplicated Alpha" }
                                Button("Delete") { status = "Deleted Alpha" }
                            }
                        Text(status)
                    }
                }
                Example("Menu that reads state") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(pinned ? "📌 Pinned note" : "Note")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(8)
                            .contextMenu {
                                Button(pinned ? "Unpin" : "Pin") { pinned.toggle() }
                                Button("Share") { status = "Shared note" }
                            }
                    }
                }
            }
        }
        .navigationTitle("Context Menu")
    }
}
