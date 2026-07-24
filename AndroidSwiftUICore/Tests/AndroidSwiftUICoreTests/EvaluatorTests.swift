//
//  EvaluatorTests.swift
//  AndroidSwiftUICoreTests
//
//  Proves the evaluation and identity semantics without a JVM or emulator.
//

import Testing
import Foundation
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

    @Test("A fixed frame with default center alignment emits no alignment")
    func frameDefaultAlignment() {
        let node = ViewHost(Text("x").frame(width: 100, height: 50)).evaluate()
        let frame = node.modifiers.first { $0.kind == "frame" }
        #expect(frame?.args["horizontal"] == nil)
        #expect(frame?.args["vertical"] == nil)
    }

    @Test("maxWidth .infinity becomes a fill flag, not a number")
    func frameFill() {
        let node = ViewHost(Text("x").frame(maxWidth: .infinity, alignment: .leading)).evaluate()
        let frame = node.modifiers.first { $0.kind == "frame" }
        #expect(frame?.args["fillWidth"] == .bool(true))
        #expect(frame?.args["maxWidth"] == nil)
        #expect(frame?.args["horizontal"] == .string("leading"))
    }

    @Test("Bounded frame emits its min and max")
    func frameBounds() {
        let node = ViewHost(Text("x").frame(minWidth: 40, maxWidth: 200, minHeight: 20)).evaluate()
        let frame = node.modifiers.first { $0.kind == "frame" }
        #expect(frame?.args["minWidth"] == .double(40))
        #expect(frame?.args["maxWidth"] == .double(200))
        #expect(frame?.args["minHeight"] == .double(20))
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

    @Test("onLongPressGesture registers its own callback distinct from a tap")
    func longPress() {
        var tapped = false
        var pressed = false
        let host = ViewHost(
            Text("x")
                .onTapGesture { tapped = true }
                .onLongPressGesture { pressed = true }
        )
        let node = host.evaluate()
        guard case .int(let tapID)? = node.modifiers.first(where: { $0.kind == "onTapGesture" })?.args["action"],
              case .int(let pressID)? = node.modifiers.first(where: { $0.kind == "longPress" })?.args["action"] else {
            Issue.record("missing gesture callbacks"); return
        }
        #expect(tapID != pressID)
        host.callbacks.invokeVoid(Int64(pressID))
        #expect(pressed)
        #expect(!tapped)
    }

    @Test("A drag reports translation to onChanged, then a final value to onEnded")
    func dragGesture() {
        var changes: [CGSize] = []
        var ended: CGSize?
        let host = ViewHost(
            Text("x").gesture(
                DragGesture()
                    .onChanged { changes.append($0.translation) }
                    .onEnded { ended = $0.translation }
            )
        )
        let node = host.evaluate()
        let drag = node.modifiers.first { $0.kind == "drag" }
        #expect(drag?.args["minimumDistance"] == .double(10))
        guard case .int(let id)? = drag?.args["action"] else {
            Issue.record("missing drag callback"); return
        }
        // the interpreter's payload: phase, start point, current point (in points)
        host.callbacks.invokeString(Int64(id), "changed;10.0,20.0;40.0,25.0")
        host.callbacks.invokeString(Int64(id), "ended;10.0,20.0;60.0,20.0")
        #expect(changes.count == 1)
        #expect(changes.first?.width == 30)    // 40 − 10
        #expect(changes.first?.height == 5)    // 25 − 20
        #expect(ended?.width == 50)
        #expect(ended?.height == 0)
    }

    @Test("A malformed drag payload is ignored rather than crashing")
    func dragGestureMalformed() {
        var changes = 0
        let host = ViewHost(
            Text("x").gesture(DragGesture().onChanged { _ in changes += 1 })
        )
        let node = host.evaluate()
        guard case .int(let id)? = node.modifiers.first(where: { $0.kind == "drag" })?.args["action"] else {
            Issue.record("missing drag callback"); return
        }
        host.callbacks.invokeString(Int64(id), "changed;garbage")
        host.callbacks.invokeString(Int64(id), "")
        #expect(changes == 0)
    }

    @Test("Image distinguishes a system symbol from a named asset")
    func imageNaming() {
        let symbol = ViewHost(Image(systemName: "star.fill")).evaluate()
        #expect(symbol.props["systemName"] == .string("star.fill"))
        let asset = ViewHost(Image("sample_photo")).evaluate()
        #expect(asset.props["name"] == .string("sample_photo"))
        #expect(asset.props["systemName"] == nil)     // not a symbol lookup
        #expect(asset.props["resizable"] == nil)      // opt-in only
    }

    @Test("resizable and a content mode travel together to the interpreter")
    func imageResizable() {
        let node = ViewHost(Image("sample_photo").resizable().scaledToFit()).evaluate()
        #expect(node.props["resizable"] == .bool(true))
        let mode = node.modifiers.first { $0.kind == "contentMode" }
        #expect(mode?.args["mode"] == .string("fit"))
        // scaledToFill and aspectRatio(contentMode:) select the other mode
        let filled = ViewHost(Image("x").resizable().scaledToFill()).evaluate()
        #expect(filled.modifiers.first { $0.kind == "contentMode" }?.args["mode"] == .string("fill"))
        let ratio = ViewHost(Image("x").aspectRatio(contentMode: .fit)).evaluate()
        #expect(ratio.modifiers.first { $0.kind == "contentMode" }?.args["mode"] == .string("fit"))
    }

    @Test("AsyncImage carries its URL, and a nil URL carries none")
    func asyncImage() {
        let node = ViewHost(AsyncImage(url: URL(string: "https://example.com/a.png"))).evaluate()
        #expect(node.type == "AsyncImage")
        #expect(node.props["url"] == .string("https://example.com/a.png"))
        let empty = ViewHost(AsyncImage(url: nil)).evaluate()
        #expect(empty.type == "AsyncImage")
        #expect(empty.props["url"] == nil)
    }

    @Test("Link carries its destination and its label")
    func link() {
        let node = ViewHost(
            Link("Swift.org", destination: URL(string: "https://swift.org")!)
        ).evaluate()
        #expect(node.type == "Link")
        #expect(node.props["url"] == .string("https://swift.org"))
        #expect(firstTextString(node) == "Swift.org")
        // no callback: the interpreter opens the address itself
        #expect(node.props["onTap"] == nil)
    }

    @Test("Link accepts an arbitrary label")
    func linkCustomLabel() {
        let node = ViewHost(
            Link(destination: URL(string: "https://example.com/docs")!) {
                HStack { Text("Read"); Text("the docs") }
            }
        ).evaluate()
        #expect(node.props["url"] == .string("https://example.com/docs"))
        #expect(node.children.first?.type == "HStack")
    }

    @Test("Label emits its icon then its title")
    func label() {
        let node = ViewHost(Label("Favorites", systemImage: "star.fill")).evaluate()
        #expect(node.type == "Label")
        #expect(node.children.count == 2)
        // order matters: the interpreter shows/hides each half by position
        #expect(node.children[0].type == "Image")
        #expect(node.children[0].props["systemName"] == .string("star.fill"))
        #expect(firstTextString(node.children[1]) == "Favorites")
    }

    @Test("Label takes an arbitrary title and icon")
    func labelCustom() {
        let node = ViewHost(
            Label(title: { Text("Hi") }, icon: { Text("!") })
        ).evaluate()
        #expect(firstTextString(node.children[0]) == "!")     // icon slot
        #expect(firstTextString(node.children[1]) == "Hi")    // title slot
    }

    @Test("labelStyle rides on the view, so it can be inherited")
    func labelStyle() {
        let node = ViewHost(
            VStack {
                Label("A", systemImage: "star")
                Label("B", systemImage: "star")
            }
            .labelStyle(.iconOnly)
        ).evaluate()
        #expect(node.modifiers.first { $0.kind == "labelStyle" }?.args["style"] == .string("iconOnly"))
        // the container carries it; the labels themselves carry none
        for child in node.children {
            #expect(child.type == "Label")
            #expect(child.modifiers.first { $0.kind == "labelStyle" } == nil)
        }
    }

    @Test("contextMenu wraps content and carries its menu items")
    func contextMenu() {
        var deleted = false
        let host = ViewHost(
            Text("Long press me")
                .contextMenu {
                    Button("Rename") {}
                    Button("Delete") { deleted = true }
                }
        )
        let node = host.evaluate()
        #expect(node.type == "ContextMenu")
        #expect(node.props["contentCount"] == .int(1))
        // 1 content + 2 menu items
        #expect(node.children.count == 3)
        #expect(firstTextString(node.children[0]) == "Long press me")

        // the menu item's callback still reaches the closure
        let deleteItem = node.children[2]
        guard case .int(let id)? = deleteItem.props["onTap"] else {
            Issue.record("menu item lost its callback"); return
        }
        host.callbacks.invokeVoid(Int64(id))
        #expect(deleted)
    }

    @Test("onAppear and onDisappear emit distinct callback kinds")
    func appearDisappear() {
        let node = ViewHost(Text("x").onAppear {}.onDisappear {}).evaluate()
        #expect(node.modifiers.contains { $0.kind == "onAppear" })
        #expect(node.modifiers.contains { $0.kind == "onDisappear" })
    }

    @Test("task emits start and cancel callback ids that drive the same Task")
    func taskStartAndCancel() async {
        let host = ViewHost(Text("x").task { try? await Task.sleep(nanoseconds: 10_000_000_000) })
        let node = host.evaluate()
        let task = node.modifiers.first { $0.kind == "task" }
        guard case .int(let start)? = task?.args["start"],
              case .int(let cancel)? = task?.args["cancel"] else {
            Issue.record("missing start/cancel ids"); return
        }
        #expect(start != cancel)
        host.callbacks.invokeVoid(Int64(start))          // launches the Task
        #expect(!_TaskRegistry.running.isEmpty)
        host.callbacks.invokeVoid(Int64(cancel))         // cancels and clears it
        #expect(_TaskRegistry.running.isEmpty)
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

    @Test("tint emits its color")
    func tint() {
        let node = ViewHost(Text("x").tint(.green)).evaluate()
        #expect(node.modifiers.first { $0.kind == "tint" }?.args["color"] == Color.green.propValue)
    }

    @Test("transition emits its kind and edge")
    func transition() {
        let node = ViewHost(Text("x").transition(.move(edge: .bottom))).evaluate()
        let transition = node.modifiers.first { $0.kind == "transition" }
        #expect(transition?.args["kind"] == .string("move"))
        #expect(transition?.args["edge"] == .string("bottom"))
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

    @Test("Map emits its region and marker children")
    func map() {
        struct Screen: View {
            @State var region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -12.046, longitude: -77.043),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            var body: some View {
                Map(coordinateRegion: $region, markers: [
                    MapMarker("Plaza", coordinate: CLLocationCoordinate2D(latitude: -12.045, longitude: -77.030)),
                ])
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.type == "Map")
        #expect(node.props["centerLatitude"] == .double(-12.046))
        #expect(node.props["spanLongitude"] == .double(0.1))
        #expect(node.children.count == 1)
        #expect(node.children[0].type == "MapMarker")
        #expect(node.children[0].props["title"] == .string("Plaza"))
        #expect(node.children[0].props["latitude"] == .double(-12.045))
    }

    @Test("VideoPlayer emits its media URL")
    func videoPlayer() {
        let node = ViewHost(VideoPlayer(player: AVPlayer(url: URL(string: "https://example.com/clip.mp4")!))).evaluate()
        #expect(node.type == "VideoPlayer")
        #expect(node.props["url"] == .string("https://example.com/clip.mp4"))
    }

    @Test("ComposableView emits a Composable node naming its factory with typed props")
    func composableView() {
        let node = ViewHost(
            ComposableView("RatingBar", props: ["rating": 3.5, "max": 5, "editable": true, "id": "abc"])
        ).evaluate()
        #expect(node.type == "Composable")
        #expect(node.props["name"] == .string("RatingBar"))
        #expect(node.props["rating"] == .double(3.5))
        #expect(node.props["max"] == .int(5))
        #expect(node.props["editable"] == .bool(true))
        #expect(node.props["id"] == .string("abc"))
    }

    @Test("ComposableView forwards child content")
    func composableViewChildren() {
        let node = ViewHost(
            ComposableView("DashedBorder") { Text("inside") }
        ).evaluate()
        #expect(node.type == "Composable")
        #expect(firstTextString(node.children.first ?? node) == "inside")
    }

    @Test("ComposableView actions register callbacks the factory can invoke")
    func composableViewActions() {
        var received = 0.0
        let host = ViewHost(
            ComposableView("RatingBar", actions: ["onRatingChanged": .double { received = $0 }])
        )
        let node = host.evaluate()
        guard case .int(let id)? = node.props["onRatingChanged"] else {
            Issue.record("missing action id"); return
        }
        host.callbacks.invokeDouble(Int64(id), 4.5)
        #expect(received == 4.5)
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

// MARK: - Animation

@Suite("Animation")
struct AnimationTests {

    @Test("A withAnimation write stamps the next tree's root, once")
    func withAnimationStampsRoot() {
        struct Screen: View {
            @State var on = false
            var body: some View { Text("x").opacity(on ? 1 : 0) }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["animationCurve"] == nil)
        // find the opacity toggle by writing through a registered callback:
        // simplest is to mutate via withAnimation around a state write driven
        // by re-linking — use onTapGesture to reach the state.
        struct Tappable: View {
            @State var on = false
            var body: some View {
                Text("x").opacity(on ? 1 : 0).onTapGesture { withAnimation(.easeIn(duration: 0.2)) { on.toggle() } }
            }
        }
        let tapHost = ViewHost(Tappable())
        node = tapHost.evaluate()
        guard case .int(let id)? = node.modifiers.first(where: { $0.kind == "onTapGesture" })?.args["action"] else {
            Issue.record("missing tap id"); return
        }
        tapHost.callbacks.invokeVoid(Int64(id))
        node = tapHost.evaluate()
        #expect(node.props["animationCurve"] == .string("easeIn"))
        #expect(node.props["animationDurationMs"] == .double(200))
        // a subsequent plain write does not animate
        node = tapHost.evaluate()
        #expect(node.props["animationCurve"] == nil)
    }

    @Test("withAnimation returns its body's value and restores the transaction")
    func withAnimationScoping() {
        let result = withAnimation(.linear(duration: 1)) { 41 + 1 }
        #expect(result == 42)
        #expect(Transaction._current == nil)
    }

    @Test(".animation emits curve, duration, and value token")
    func implicitAnimation() {
        let node = ViewHost(Text("x").animation(.spring(), value: 3)).evaluate()
        let anim = node.modifiers.first { $0.kind == "animation" }
        #expect(anim?.args["curve"] == .string("spring"))
        #expect(anim?.args["token"] == .string("3"))
    }
}

@Suite("Geometry")
struct GeometryTests {

    /// Finds a GeometryReader's size-report callback anywhere in a tree.
    private func sizeCallback(_ node: RenderNode) -> Int64? {
        if node.type == "GeometryReader", case .int(let id)? = node.props["onSize"] {
            return Int64(id)
        }
        for child in node.children {
            if let found = sizeCallback(child) { return found }
        }
        return nil
    }

    @Test("A GeometryReader resolves against zero until a size is reported")
    func geometrySettlesOverTwoPasses() {
        struct Screen: View {
            var body: some View {
                GeometryReader { geometry in
                    Text("w=\(Int(geometry.size.width)) h=\(Int(geometry.size.height))")
                }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.type == "GeometryReader")
        // first pass: layout hasn't happened, so the proxy reads zero
        #expect(firstTextString(node) == "w=0 h=0")

        guard let report = sizeCallback(node) else {
            Issue.record("missing size callback"); return
        }
        host.callbacks.invokeString(report, "320.0,240.0")
        node = host.evaluate()
        // second pass: the reported size reaches the content
        #expect(firstTextString(node) == "w=320 h=240")
    }

    @Test("The size store re-evaluates on a change and ignores everything else")
    func geometryStoreSettles() {
        // Driving the store directly is the precise way to pin the settling
        // rule: without it a steady layout would re-evaluate forever.
        let store = GeometrySizeStore()
        var changes = 0
        store.onChange = { changes += 1 }

        store.update(from: "100.0,50.0")
        #expect(changes == 1)
        #expect(store.size.width == 100)
        #expect(store.size.height == 50)

        store.update(from: "100.0,50.0")
        #expect(changes == 1)          // same size — layout has settled

        store.update(from: "180.0,50.0")
        #expect(changes == 2)          // a real change reports again
        #expect(store.size.width == 180)

        store.update(from: "garbage")
        store.update(from: "")
        store.update(from: "1.0")      // too few components
        #expect(changes == 2)          // malformed reports never re-evaluate
        #expect(store.size.width == 180)
    }
}

private struct MaxWidthKey: PreferenceKey {
    static var defaultValue: Double { 0 }
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = max(value, nextValue())
    }
}

private struct NamesKey: PreferenceKey {
    static var defaultValue: [String] { [] }
    static func reduce(value: inout [String], nextValue: () -> [String]) {
        value += nextValue()
    }
}

@Suite("Preferences")
struct PreferenceTests {

    @Test("An ancestor sees its subtree's preferences reduced")
    func reducesAcrossSubtree() {
        var seen: Double?
        let host = ViewHost(
            VStack {
                Text("a").preference(key: MaxWidthKey.self, value: 40)
                Text("b").preference(key: MaxWidthKey.self, value: 120)
                Text("c").preference(key: MaxWidthKey.self, value: 80)
            }
            .onPreferenceChange(MaxWidthKey.self) { seen = $0 }
        )
        _ = host.evaluate()
        #expect(seen == 120)          // reduce kept the largest
    }

    @Test("Reduce runs in tree order and starts from the default")
    func reducesInOrder() {
        var seen: [String]?
        let host = ViewHost(
            VStack {
                Text("x").preference(key: NamesKey.self, value: ["first"])
                Text("y").preference(key: NamesKey.self, value: ["second"])
            }
            .onPreferenceChange(NamesKey.self) { seen = $0 }
        )
        _ = host.evaluate()
        #expect(seen == ["first", "second"])
    }

    @Test("A subtree that publishes nothing delivers the default")
    func deliversDefault() {
        var seen: Double = -1
        let host = ViewHost(
            VStack { Text("nothing here") }
                .onPreferenceChange(MaxWidthKey.self) { seen = $0 }
        )
        _ = host.evaluate()
        #expect(seen == 0)
    }

    @Test("An unchanged reduction doesn't fire the callback again")
    func settlesWhenUnchanged() {
        // The callback normally writes state, so re-delivering an unchanged
        // value would re-evaluate forever.
        final class Counter: @unchecked Sendable { var count = 0 }
        let counter = Counter()
        struct Screen: View {
            let counter: Counter
            @State var bump = 0
            var body: some View {
                VStack {
                    Text("\(bump)").preference(key: MaxWidthKey.self, value: 50)
                }
                .onPreferenceChange(MaxWidthKey.self) { _ in counter.count += 1 }
            }
        }
        let host = ViewHost(Screen(counter: counter))
        _ = host.evaluate()
        #expect(counter.count == 1)
        _ = host.evaluate()
        _ = host.evaluate()
        #expect(counter.count == 1)   // same value across passes — delivered once
    }

    @Test("Chained observers watching different keys each get their own")
    func chainedObserversDifferentKeys() {
        // An observer scopes a collector to its subtree. If it only forwarded
        // the key it watches, the outer observer here would see nothing —
        // which is exactly what happened before propagate(into:).
        var widest: Double?
        var collected: [String]?
        let host = ViewHost(
            VStack {
                Text("a").preference(key: MaxWidthKey.self, value: 30)
                    .preference(key: NamesKey.self, value: ["a"])
                Text("b").preference(key: MaxWidthKey.self, value: 90)
                    .preference(key: NamesKey.self, value: ["b"])
            }
            .onPreferenceChange(MaxWidthKey.self) { widest = $0 }
            .onPreferenceChange(NamesKey.self) { collected = $0 }
        )
        _ = host.evaluate()
        #expect(widest == 90)
        #expect(collected == ["a", "b"])
    }

    @Test("Chained observers settle instead of re-evaluating forever")
    func chainedObserversSettle() {
        // Chained observers share an identity path. If their change-memos also
        // shared a storage key they would overwrite each other every pass, so
        // every delivery would look new and the callbacks — which write state —
        // would re-evaluate without end. This hung the app on device.
        final class Counter: @unchecked Sendable {
            var widest = 0
            var names = 0
        }
        let counter = Counter()
        struct Screen: View {
            let counter: Counter
            var body: some View {
                VStack {
                    Text("a").preference(key: MaxWidthKey.self, value: 30)
                        .preference(key: NamesKey.self, value: ["a"])
                }
                .onPreferenceChange(MaxWidthKey.self) { _ in counter.widest += 1 }
                .onPreferenceChange(NamesKey.self) { _ in counter.names += 1 }
            }
        }
        let host = ViewHost(Screen(counter: counter))
        for _ in 0 ..< 5 { _ = host.evaluate() }
        #expect(counter.widest == 1)   // delivered once, then quiet
        #expect(counter.names == 1)
    }

    @Test("A nested observer consumes its subtree yet still publishes upward")
    func nestedObserversCompose() {
        var inner: Double?
        var outer: Double?
        let host = ViewHost(
            VStack {
                VStack {
                    Text("deep").preference(key: MaxWidthKey.self, value: 70)
                }
                .onPreferenceChange(MaxWidthKey.self) { inner = $0 }
                Text("shallow").preference(key: MaxWidthKey.self, value: 30)
            }
            .onPreferenceChange(MaxWidthKey.self) { outer = $0 }
        )
        _ = host.evaluate()
        #expect(inner == 70)
        #expect(outer == 70)          // the inner reduction reached the outer one
    }
}

@Suite("Accessibility")
struct AccessibilityTests {

    private func arg(_ node: RenderNode, _ kind: String, _ key: String) -> PropValue? {
        node.modifiers.first { $0.kind == kind }?.args[key]
    }

    @Test("Label, value, and identifier emit their text")
    func describes() {
        let node = ViewHost(
            Text("7")
                .accessibilityLabel("Unread messages")
                .accessibilityValue("7 items")
                .accessibilityIdentifier("inbox-count")
        ).evaluate()
        #expect(arg(node, "accessibilityLabel", "text") == .string("Unread messages"))
        #expect(arg(node, "accessibilityValue", "text") == .string("7 items"))
        #expect(arg(node, "accessibilityIdentifier", "id") == .string("inbox-count"))
    }

    @Test("Hiding is explicit in both directions")
    func hidden() {
        let hidden = ViewHost(Text("decorative").accessibilityHidden(true)).evaluate()
        #expect(arg(hidden, "accessibilityHidden", "value") == .bool(true))
        // false must still emit — it has to be able to override an inherited hide
        let shown = ViewHost(Text("visible").accessibilityHidden(false)).evaluate()
        #expect(arg(shown, "accessibilityHidden", "value") == .bool(false))
    }

    @Test("Traits emit as a set of names")
    func traits() {
        let node = ViewHost(
            Text("Chapter").accessibilityAddTraits([.isHeader, .isButton])
        ).evaluate()
        guard case .array(let names)? = arg(node, "accessibilityAddTraits", "traits") else {
            Issue.record("missing traits"); return
        }
        #expect(names.contains(.string("header")))
        #expect(names.contains(.string("button")))
        #expect(!names.contains(.string("selected")))
    }


    @Test("Accessibility describes without disturbing the view")
    func nonVisual() {
        // the node type, props, and children must be identical with and without
        // a description — these modifiers only add semantics
        let plain = ViewHost(VStack { Text("hello") }).evaluate()
        let described = ViewHost(
            VStack { Text("hello") }.accessibilityLabel("greeting")
        ).evaluate()
        #expect(plain.type == described.type)
        #expect(plain.children.count == described.children.count)
        #expect(firstTextString(plain) == firstTextString(described))
    }
}

@Suite("DisclosureGroup")
struct DisclosureGroupTests {

    @Test("Emits its label then its content, marking the boundary")
    func labelThenContent() {
        let node = ViewHost(
            DisclosureGroup("Advanced") {
                Text("row one")
                Text("row two")
            }
        ).evaluate()
        #expect(node.type == "DisclosureGroup")
        #expect(node.props["labelCount"] == .int(1))
        #expect(node.children.count == 3)           // 1 label + 2 content
        #expect(firstTextString(node.children[0]) == "Advanced")
        #expect(firstTextString(node.children[1]) == "row one")
        // unbound: the interpreter owns expansion, so no state crosses
        #expect(node.props["isExpanded"] == nil)
        #expect(node.props["onToggle"] == nil)
    }

    @Test("A bound group round-trips its expansion")
    func boundExpansion() {
        struct Screen: View {
            @State var open = false
            var body: some View {
                DisclosureGroup("Details", isExpanded: $open) { Text("hidden") }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["isExpanded"] == .bool(false))
        guard case .int(let id)? = node.props["onToggle"] else {
            Issue.record("missing toggle callback"); return
        }
        host.callbacks.invokeBool(Int64(id), true)
        node = host.evaluate()
        #expect(node.props["isExpanded"] == .bool(true))
    }

    @Test("Accepts a view label, not only a title")
    func viewLabel() {
        let node = ViewHost(
            DisclosureGroup(content: { Text("body") }, label: {
                Label("Section", systemImage: "star")
            })
        ).evaluate()
        #expect(node.props["labelCount"] == .int(1))
        #expect(node.children[0].type == "Label")
    }
}
