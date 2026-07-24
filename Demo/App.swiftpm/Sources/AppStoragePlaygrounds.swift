#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct AppStoragePlayground: View {

    @AppStorage("demo.launches") private var launches = 0
    @AppStorage("demo.nickname") private var nickname = ""
    @AppStorage("demo.notify") private var notify = false
    @AppStorage("demo.volume") private var volume = 0.5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Survives a relaunch") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Counter: \(launches)")
                        Text("Kill and reopen the app — it keeps its value.")
                        Button("Increment") { launches += 1 }
                        Button("Reset") { launches = 0 }
                    }
                }
                Example("String") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Nickname", text: $nickname)
                        Text("Stored: \(nickname)")
                    }
                }
                Example("Bool") {
                    Toggle("Notifications", isOn: $notify)
                }
                Example("Double") {
                    VStack(alignment: .leading, spacing: 8) {
                        Slider(value: $volume, in: 0...1)
                        Text("Volume: \(Int(volume * 100))%")
                    }
                }
            }
        }
        .navigationTitle("AppStorage")
    }
}
