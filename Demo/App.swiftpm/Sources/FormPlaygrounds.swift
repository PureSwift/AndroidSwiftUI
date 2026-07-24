#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct FormPlayground: View {
    @State private var wifi = true
    @State private var bluetooth = false
    @State private var brightness = 0.6
    @State private var name = ""
    var body: some View {
        Form {
            Section("Connectivity") {
                Toggle("Wi-Fi", isOn: $wifi)
                Toggle("Bluetooth", isOn: $bluetooth)
            }
            Section(header: "Display", footer: "Drag to adjust the screen brightness.") {
                Slider(value: $brightness, in: 0...1)
                HStack { Text("Level"); Spacer(); Text("\(Int(brightness * 100))%") }
            }
            Section("Account") {
                TextField("Name", text: $name)
                HStack { Text("Status"); Spacer(); Text(name.isEmpty ? "Guest" : name) }
            }
        }
    }
}
