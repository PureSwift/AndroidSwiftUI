#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct MoreControlsPlayground: View {
    @State private var quantity = 1
    @State private var password = ""
    @State private var choice = "None"
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Stepper") {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 0...10)
                }
                Example("SecureField") {
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("Password", text: $password)
                        Text(password.isEmpty ? "Nothing typed yet" : "\(password.count) characters")
                    }
                }
                Example("Menu") {
                    VStack(alignment: .leading, spacing: 8) {
                        Menu("Actions") {
                            Button("Rename") { choice = "Rename" }
                            Button("Duplicate") { choice = "Duplicate" }
                            Button("Delete") { choice = "Delete" }
                        }
                        Text("Chose: \(choice)")
                    }
                }
            }
        }
    }
}
