#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

import Foundation

struct MoreControlsPlayground: View {
    @State private var quantity = 1
    @State private var password = ""
    @State private var choice = "None"
    @State private var birthday = Date(timeIntervalSince1970: 946_684_800) // 2000-01-01T00:00:00Z
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Stepper") {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 0...10)
                }
                Example("DatePicker") {
                    DatePicker("Birthday", selection: $birthday)
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
