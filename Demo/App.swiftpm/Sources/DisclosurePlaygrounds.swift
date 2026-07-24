#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct DisclosurePlayground: View {

    @State private var advancedOpen = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Self-managed expansion") {
                    DisclosureGroup("What's included") {
                        Text("• Unlimited projects")
                        Text("• Priority support")
                        Text("• Early access")
                    }
                }
                Example("Bound expansion") {
                    VStack(alignment: .leading, spacing: 8) {
                        DisclosureGroup("Advanced settings", isExpanded: $advancedOpen) {
                            Text("Experimental features live here.")
                            Toggle("Beta channel", isOn: .constant(true))
                        }
                        Button(advancedOpen ? "Collapse from outside" : "Expand from outside") {
                            advancedOpen.toggle()
                        }
                    }
                }
                Example("With a Label header") {
                    DisclosureGroup(content: {
                        Text("Grouped under a labeled header.")
                    }, label: {
                        Label("Notifications", systemImage: "star.fill")
                    })
                }
            }
        }
        .navigationTitle("DisclosureGroup")
    }
}
