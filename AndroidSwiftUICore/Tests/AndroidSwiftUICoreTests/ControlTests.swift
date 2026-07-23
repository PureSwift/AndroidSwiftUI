//
//  ControlTests.swift
//  AndroidSwiftUICoreTests
//

import Testing
@testable import AndroidSwiftUICore

#if canImport(Observation)
import Observation

@Observable final class ObservableModel { var counter = 0; var name = "" }
#endif

@Suite("Controls and environment")
struct ControlTests {

    @Test("Slider emits value, bounds, and a working double callback")
    func slider() {
        struct Screen: View {
            @State var value = 0.5
            var body: some View { Slider(value: $value, in: 0...1) }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["value"] == .double(0.5))
        if case .int(let id)? = node.props["onChange"] {
            host.callbacks.invokeDouble(Int64(id), 0.75)
        }
        node = host.evaluate()
        #expect(node.props["value"] == .double(0.75))
    }

    @Test("TextField round-trips its binding through the string callback")
    func textField() {
        struct Screen: View {
            @State var name = ""
            var body: some View { TextField("Name", text: $name) }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["text"] == .string(""))
        if case .int(let id)? = node.props["onChange"] {
            host.callbacks.invokeString(Int64(id), "Coleman")
        }
        node = host.evaluate()
        #expect(node.props["text"] == .string("Coleman"))
    }

    @Test("Picker emits tagged children and maps the selection string back")
    func picker() {
        struct Screen: View {
            @State var fruit = "Apple"
            var body: some View {
                Picker("Fruit", selection: $fruit) {
                    Text("Apple").tag("Apple")
                    Text("Banana").tag("Banana")
                }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["selection"] == .string("Apple"))
        #expect(node.children.count == 2)
        // each child carries its tag as a modifier
        let tags = node.children.compactMap { child -> String? in
            guard let tag = child.modifiers.first(where: { $0.kind == "tag" }),
                  case .string(let value)? = tag.args["value"] else { return nil }
            return value
        }
        #expect(tags == ["Apple", "Banana"])
        if case .int(let id)? = node.props["onChange"] {
            host.callbacks.invokeString(Int64(id), "Banana")
        }
        node = host.evaluate()
        #expect(node.props["selection"] == .string("Banana"))
    }

    @Test("Stepper increments and decrements within bounds, updating its label")
    func stepper() {
        struct Screen: View {
            @State var count = 5
            var body: some View { Stepper("Count: \(count)", value: $count, in: 0...10) }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.type == "Stepper")
        if case .int(let inc)? = node.props["onIncrement"] { host.callbacks.invokeVoid(Int64(inc)) }
        node = host.evaluate()
        #expect(firstTextString(node) == "Count: 6")
        if case .int(let dec)? = node.props["onDecrement"] { host.callbacks.invokeVoid(Int64(dec)) }
        node = host.evaluate()
        #expect(firstTextString(node) == "Count: 5")
    }

    @Test("SecureField emits a secure TextField node")
    func secureField() {
        struct Screen: View {
            @State var password = ""
            var body: some View { SecureField("Password", text: $password) }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.type == "TextField")
        #expect(node.props["secure"] == .bool(true))
    }

    @Test("Menu emits its label and item children")
    func menu() {
        let node = ViewHost(Menu("Options") {
            Button("First") {}
            Button("Second") {}
        }).evaluate()
        #expect(node.type == "Menu")
        #expect(node.props["label"] == .string("Options"))
        #expect(node.children.count == 2)
    }

    @Test("Environment objects reach @Environment properties in the subtree")
    func environmentInjection() {
        final class Model { var value = 42 }
        struct Child: View {
            @Environment(Model.self) var model
            var body: some View { Text("value \(model.value)") }
        }
        struct Screen: View {
            let model: Model
            var body: some View { Child().environment(model) }
        }
        let node = ViewHost(Screen(model: Model())).evaluate()
        #expect(node.props["text"] == .string("value 42"))
    }

    #if canImport(Observation)
    @Test("@Observable mutation triggers the state-change hook")
    func observation() {
        struct Screen: View {
            let model: ObservableModel
            var body: some View { Text("count \(model.counter)") }
        }
        let model = ObservableModel()
        let host = ViewHost(Screen(model: model))
        var fired = false
        host.onStateChange = { fired = true }
        var node = host.evaluate()
        #expect(node.props["text"] == .string("count 0"))
        model.counter += 1
        #expect(fired)
        node = host.evaluate()
        #expect(node.props["text"] == .string("count 1"))
    }

    @Test("@Bindable projects a two-way binding into an observable model")
    func bindableProjection() {
        let model = ObservableModel()
        @Bindable var bound = model
        let binding = $bound.name
        binding.wrappedValue = "hi"
        #expect(model.name == "hi")
        #expect(binding.wrappedValue == "hi")
    }

    @Test("A TextField bound via @Bindable writes back to the model")
    func bindableTextField() {
        struct Screen: View {
            @Bindable var model: ObservableModel
            var body: some View { TextField("Name", text: $model.name) }
        }
        let model = ObservableModel()
        let host = ViewHost(Screen(model: model))
        var node = host.evaluate()
        #expect(node.props["text"] == .string(""))
        if case .int(let id)? = node.props["onChange"] {
            host.callbacks.invokeString(Int64(id), "Coleman")
        }
        #expect(model.name == "Coleman")
        node = host.evaluate()
        #expect(node.props["text"] == .string("Coleman"))
    }
    #endif
}
