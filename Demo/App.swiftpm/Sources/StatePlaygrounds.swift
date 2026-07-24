#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

import Observation

struct StatePlayground: View {
    @State private var parentRenders = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Parent re-renders: \(parentRenders)") {
                    Button("Re-render parent") { parentRenders += 1 }
                }
                Example("Child keeps its own state") {
                    StateChild()
                }
            }
        }
    }
}

struct StateChild: View {
    @State private var localCount = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Local count: \(localCount)")
            Button("Bump child") { localCount += 1 }
            Text("Survives parent re-renders")
        }
    }
}

@Observable
final class CounterModel {
    var value = 0
}

struct EnvironmentPlayground: View {
    @State private var model = CounterModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Injected object") {
                    EnvReader().environment(model)
                }
                Example("Read here too") {
                    EnvReader().environment(model)
                }
            }
        }
    }
}

struct EnvReader: View {
    @Environment(CounterModel.self) private var model
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shared value: \(model.value)")
            Button("Increment shared") { model.value += 1 }
        }
    }
}

struct ObservablePlayground: View {
    @State private var model = CounterModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Observation drives updates") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Observable value: \(model.value)")
                        Button("Increment") { model.value += 1 }
                        Text("Mutating the model re-evaluates automatically")
                    }
                }
            }
        }
    }
}
