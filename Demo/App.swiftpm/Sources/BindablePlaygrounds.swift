#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

import Observation

@Observable
final class ProfileModel {
    var name = ""
    var subscribed = false
    var volume = 0.5
}

struct BindablePlayground: View {
    @State private var model = ProfileModel()
    var body: some View {
        ScrollView {
            BindableForm(model: model)
        }
    }
}

/// `@Bindable` takes the model by reference and projects `$model.property`
/// bindings into it; writing a bound control mutates the observable, which
/// re-evaluates the views that read it.
struct BindableForm: View {
    @Bindable var model: ProfileModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Example("Bound TextField") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Name", text: $model.name)
                    Text(model.name.isEmpty ? "No name yet" : "Hello, \(model.name)")
                }
            }
            Example("Bound Toggle") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Subscribed", isOn: $model.subscribed)
                    Text(model.subscribed ? "Subscribed" : "Not subscribed")
                }
            }
            Example("Bound Slider") {
                VStack(alignment: .leading, spacing: 8) {
                    Slider(value: $model.volume, in: 0...1)
                    Text("Volume: \(Int(model.volume * 100))%")
                }
            }
            Example("Shared model") {
                Text("All three controls above bind into one @Observable model.")
            }
        }
    }
}
