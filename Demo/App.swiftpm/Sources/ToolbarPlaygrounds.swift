#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct ToolbarPlayground: View {

    @State private var score = 0
    @State private var principalTitle = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Score: \(score)")
                Text("Save adds 1, Flag adds 10, the bottom action adds 100.")
                Button(principalTitle ? "Use the plain title" : "Use a principal title") {
                    principalTitle.toggle()
                }
            }
            .padding()
        }
        .navigationTitle("Toolbar")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Flag") { score += 10 }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { score += 1 }
            }
            if principalTitle {
                ToolbarItem(placement: .principal) {
                    Text("Principal")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Bottom action") { score += 100 }
            }
        }
    }
}
