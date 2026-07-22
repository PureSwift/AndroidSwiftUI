//
//  EvaluatorTests.swift
//  AndroidSwiftUICoreTests
//
//  Proves the evaluation and identity semantics without a JVM or emulator.
//

import Testing
@testable import AndroidSwiftUICore

// MARK: - Emission

@Suite("Node emission")
struct EmissionTests {

    @Test("Text emits a Text node with its content")
    func text() {
        let host = ViewHost(Text("Hello"))
        let node = host.evaluate()
        #expect(node.type == "Text")
        #expect(node.props["text"] == .string("Hello"))
    }

    @Test("VStack resolves its children in order")
    func vstackChildren() {
        struct Screen: View {
            var body: some View {
                VStack {
                    Text("A")
                    Text("B")
                    Text("C")
                }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.type == "VStack")
        #expect(node.children.map(\.type) == ["Text", "Text", "Text"])
        #expect(node.children.map { $0.props["text"] } == [.string("A"), .string("B"), .string("C")])
    }

    @Test("Parameter-pack ViewBuilder has no child-count ceiling")
    func manyChildren() {
        struct Screen: View {
            var body: some View {
                VStack {
                    Text("1"); Text("2"); Text("3"); Text("4"); Text("5"); Text("6")
                    Text("7"); Text("8"); Text("9"); Text("10"); Text("11"); Text("12")
                }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.children.count == 12)
    }

    @Test("Composite views are unwrapped through their body")
    func compositeUnwrap() {
        struct Label: View {
            let text: String
            var body: some View { Text(text) }
        }
        struct Screen: View {
            var body: some View { VStack { Label(text: "X"); Label(text: "Y") } }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.children.map { $0.props["text"] } == [.string("X"), .string("Y")])
    }

    @Test("ForEach expands each element")
    func forEach() {
        struct Screen: View {
            var body: some View {
                VStack { ForEach(1...3, id: \.self) { Text("row \($0)") } }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.children.map { $0.props["text"] }
            == [.string("row 1"), .string("row 2"), .string("row 3")])
    }
}

// MARK: - Modifiers

@Suite("Modifiers")
struct ModifierTests {

    @Test("Modifier chain is emitted outermost-first, matching Compose order")
    func chainOrder() {
        let host = ViewHost(Text("x").padding(8).background(.blue))
        let node = host.evaluate()
        // SwiftUI `.padding().background()` = blue extends around the padding.
        // In Compose that's `Modifier.background().padding()` (background outermost
        // fills the region, padding insets the content), so the outermost SwiftUI
        // modifier is first in the emitted chain.
        #expect(node.modifiers.map(\.kind) == ["background", "padding"])
    }

    @Test("Modifiers don't introduce structural identity")
    func modifierTransparentToIdentity() {
        let plain = ViewHost(Text("x")).evaluate()
        let modified = ViewHost(Text("x").padding()).evaluate()
        #expect(plain.id == modified.id)
    }

    @Test("Frame emits width and height args")
    func frame() {
        let node = ViewHost(Text("x").frame(width: 100, height: 50)).evaluate()
        let frame = node.modifiers.first { $0.kind == "frame" }
        #expect(frame?.args["width"] == .double(100))
        #expect(frame?.args["height"] == .double(50))
    }
}
