#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct ControlStylePlayground: View {

    @State private var flavor = "Vanilla"
    @State private var notify = true
    @State private var name = ""

    private let flavors = ["Vanilla", "Cocoa", "Mint"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("buttonStyle") {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("automatic") {}
                        Button("bordered") {}.buttonStyle(.bordered)
                        Button("borderedProminent") {}.buttonStyle(.borderedProminent)
                        Button("plain") {}.buttonStyle(.plain)
                    }
                }
                Example("Inherited by a container") {
                    // one style, applied once, styles both buttons
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Inherited one") {}
                        Button("Inherited two") {}
                    }
                    .buttonStyle(.bordered)
                }
                Example("pickerStyle") {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Menu", selection: $flavor) {
                            ForEach(flavors, id: \.self) { Text($0).tag($0) }
                        }
                        Picker("Segmented", selection: $flavor) {
                            ForEach(flavors, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        Picker("Inline", selection: $flavor) {
                            ForEach(flavors, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.inline)
                        Text("Chosen: \(flavor)")
                    }
                }
                Example("toggleStyle") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("switch", isOn: $notify)
                        Toggle("checkbox", isOn: $notify).toggleStyle(.checkbox)
                        Toggle("button", isOn: $notify).toggleStyle(.button)
                    }
                }
                Example("textFieldStyle") {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("rounded border", text: $name)
                        TextField("plain", text: $name).textFieldStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Control Styles")
    }
}
