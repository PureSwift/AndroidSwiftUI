#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct AccessibilityPlayground: View {

    @State private var unread = 7

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("accessibilityLabel") {
                    // reads as "Unread messages", not "7"
                    Text("7")
                        .accessibilityLabel("Unread messages")
                }
                Example("accessibilityValue") {
                    Text("Volume")
                        .accessibilityLabel("Volume")
                        .accessibilityValue("30 percent")
                }
                Example("accessibilityHidden") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("kept in the tree")
                        Text("decorative-flourish")
                            .accessibilityHidden(true)
                    }
                }
                Example("accessibilityAddTraits") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chapter One")
                            .accessibilityAddTraits(.isHeader)
                        Text("Tap to continue")
                            .accessibilityAddTraits(.isButton)
                    }
                }
                Example("accessibilityIdentifier") {
                    Text("Checkout")
                        .accessibilityIdentifier("checkout-button")
                }
            }
        }
        .navigationTitle("Accessibility")
    }
}
