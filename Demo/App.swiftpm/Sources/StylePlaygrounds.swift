#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct StylePlayground: View {
    @State private var taps = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Inherited font") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("All three")
                        Text("inherit the")
                        Text("title font")
                    }
                    .font(.title)
                }
                Example("Inherited color") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Both lines are")
                        Text("blue from the container")
                    }
                    .foregroundColor(.blue)
                }
                Example("Child overrides parent") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title by inheritance")
                        Text("Caption overrides").font(.caption)
                    }
                    .font(.title)
                }
                Example("Font and color together") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Headline weight")
                        Text("and purple color")
                    }
                    .font(.headline)
                    .foregroundColor(.purple)
                }
                Example("Inherited disabled") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Both buttons are disabled (taps: \(taps))")
                        Button("First") { taps += 1 }
                        Button("Second") { taps += 1 }
                    }
                    .disabled(true)
                }
            }
        }
    }
}
