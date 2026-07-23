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

    @Test("Named font emits its style")
    func fontStyle() {
        let node = ViewHost(Text("x").font(.headline)).evaluate()
        let font = node.modifiers.first { $0.kind == "font" }
        #expect(font?.args["style"] == .string("headline"))
        #expect(font?.args["size"] == nil)
    }

    @Test("System font emits size and weight")
    func systemFont() {
        let node = ViewHost(Text("x").font(.system(size: 24, weight: .heavy))).evaluate()
        let font = node.modifiers.first { $0.kind == "font" }
        #expect(font?.args["size"] == .double(24))
        #expect(font?.args["weight"] == .string("heavy"))
    }

    @Test("foregroundColor emits an argb color")
    func foregroundColor() {
        let node = ViewHost(Text("x").foregroundColor(.red)).evaluate()
        let color = node.modifiers.first { $0.kind == "foregroundColor" }
        #expect(color?.args["color"] == Color.red.propValue)
    }

    @Test("bold and italic emit their kinds")
    func boldItalic() {
        let node = ViewHost(Text("x").bold().italic()).evaluate()
        let weight = node.modifiers.first { $0.kind == "fontWeight" }
        #expect(weight?.args["weight"] == .string("bold"))
        #expect(node.modifiers.contains { $0.kind == "italic" })
    }

    @Test("lineLimit emits its count")
    func lineLimit() {
        let node = ViewHost(Text("x").lineLimit(2)).evaluate()
        let limit = node.modifiers.first { $0.kind == "lineLimit" }
        #expect(limit?.args["count"] == .int(2))
    }

    @Test("onTapGesture registers a callback and emits its id")
    func onTapGesture() {
        var tapped = false
        let host = ViewHost(Text("x").onTapGesture { tapped = true })
        let node = host.evaluate()
        let tap = node.modifiers.first { $0.kind == "onTapGesture" }
        guard case .int(let id)? = tap?.args["action"] else {
            Issue.record("missing action id"); return
        }
        host.callbacks.invokeVoid(Int64(id))
        #expect(tapped)
    }

    @Test("onAppear and onDisappear emit distinct callback kinds")
    func appearDisappear() {
        let node = ViewHost(Text("x").onAppear {}.onDisappear {}).evaluate()
        #expect(node.modifiers.contains { $0.kind == "onAppear" })
        #expect(node.modifiers.contains { $0.kind == "onDisappear" })
    }

    @Test("onChange emits a token describing the observed value")
    func onChange() {
        let node = ViewHost(Text("x").onChange(of: 42) {}).evaluate()
        let change = node.modifiers.first { $0.kind == "onChange" }
        #expect(change?.args["token"] == .string("42"))
    }

    @Test("disabled emits its flag")
    func disabled() {
        let node = ViewHost(Text("x").disabled(true)).evaluate()
        let flag = node.modifiers.first { $0.kind == "disabled" }
        #expect(flag?.args["value"] == .bool(true))
    }

    @Test("Border emits its color and width")
    func border() {
        let node = ViewHost(Text("x").border(.blue, width: 2)).evaluate()
        let border = node.modifiers.first { $0.kind == "border" }
        #expect(border?.args["color"] == Color.blue.propValue)
        #expect(border?.args["width"] == .double(2))
    }

    @Test("clipShape emits the shape kind")
    func clipShape() {
        let node = ViewHost(Text("x").clipShape(Circle())).evaluate()
        #expect(node.modifiers.contains { $0.kind == "clipShape" && $0.args["shape"] == .string("circle") })
    }

    @Test("shadow emits its radius")
    func shadow() {
        let node = ViewHost(Text("x").shadow(radius: 6)).evaluate()
        #expect(node.modifiers.first { $0.kind == "shadow" }?.args["radius"] == .double(6))
    }
}

// MARK: - Graphics

@Suite("Graphics")
struct GraphicsTests {

    @Test("Shapes emit a Shape node with their kind and fill")
    func shapes() {
        let rect = ViewHost(Rectangle().fill(.blue)).evaluate()
        #expect(rect.type == "Shape")
        #expect(rect.props["shape"] == .string("rectangle"))
        #expect(rect.props["fill"] == Color.blue.propValue)

        let rounded = ViewHost(RoundedRectangle(cornerRadius: 12)).evaluate()
        #expect(rounded.props["shape"] == .string("roundedRectangle"))
        #expect(rounded.props["cornerRadius"] == .double(12))

        #expect(ViewHost(Circle()).evaluate().props["shape"] == .string("circle"))
        #expect(ViewHost(Capsule()).evaluate().props["shape"] == .string("capsule"))
    }

    @Test("LinearGradient emits its colors and endpoints")
    func gradient() {
        let node = ViewHost(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)).evaluate()
        #expect(node.type == "LinearGradient")
        #expect(node.props["colors"] == .array([Color.blue.propValue, Color.purple.propValue]))
        #expect(node.props["startX"] == .double(0))
        #expect(node.props["endX"] == .double(1))
    }

    @Test("Image(systemName:) carries the symbol name")
    func systemImage() {
        let node = ViewHost(Image(systemName: "star.fill")).evaluate()
        #expect(node.type == "Image")
        #expect(node.props["systemName"] == .string("star.fill"))
    }

    @Test("Overlay emits base and overlay children with alignment")
    func overlay() {
        let node = ViewHost(Color.blue.overlay(alignment: .bottomTrailing) { Text("badge") }).evaluate()
        #expect(node.type == "Overlay")
        #expect(node.children.count == 2)
        #expect(node.children[0].type == "Color")
        #expect(firstTextString(node.children[1]) == "badge")
        #expect(node.props["horizontal"] == .string("trailing"))
        #expect(node.props["vertical"] == .string("bottom"))
    }
}
