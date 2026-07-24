//
//  NavigationTests.swift
//  AndroidSwiftUICoreTests
//

import Testing
@testable import AndroidSwiftUICore

@Suite("Navigation, sheets, tabs")
struct NavigationTests {

    @Test("NavigationStack starts with only its root screen")
    func rootOnly() {
        struct Screen: View {
            var body: some View {
                NavigationStack {
                    Text("Root").navigationTitle("Home")
                }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.type == "NavStack")
        #expect(node.children.count == 1)
        if case .array(let titles)? = node.props["titles"] {
            #expect(titles == [.string("Home")])
        } else {
            Issue.record("no titles")
        }
    }

    @Test("A NavigationLink push adds a screen and its title")
    func classicPush() {
        struct Detail: View {
            var body: some View { Text("Detail").navigationTitle("Detail") }
        }
        struct Screen: View {
            var body: some View {
                NavigationStack {
                    NavigationLink("Go", destination: Detail())
                        .navigationTitle("Home")
                }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.children.count == 1)
        // tap the link (found in the root screen's subtree)
        let linkID = findOnTap(node)
        #expect(linkID != nil)
        host.callbacks.invokeVoid(linkID!)
        node = host.evaluate()
        #expect(node.children.count == 2)
        if case .array(let titles)? = node.props["titles"] {
            #expect(titles == [.string("Home"), .string("Detail")])
        }
    }

    @Test("Value-based push resolves through navigationDestination")
    func valuePush() {
        struct Screen: View {
            var body: some View {
                NavigationStack {
                    NavigationLink("Push 1", value: 1)
                        .navigationDestination(for: Int.self) { value in
                            Text("Value \(value)").navigationTitle("V\(value)")
                        }
                }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        host.callbacks.invokeVoid(findOnTap(node)!)
        node = host.evaluate()
        #expect(node.children.count == 2)
        if case .array(let titles)? = node.props["titles"] {
            #expect(titles.last == .string("V1"))
        }
    }

    @Test("dismiss pops the pushed screen")
    func dismissPops() {
        struct Detail: View {
            @Environment(\.dismiss) var dismiss
            var body: some View { Button("Back") { dismiss() } }
        }
        struct Screen: View {
            var body: some View {
                NavigationStack { NavigationLink("Go", destination: Detail()) }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        host.callbacks.invokeVoid(findOnTap(node)!)          // push
        node = host.evaluate()
        #expect(node.children.count == 2)
        host.callbacks.invokeVoid(findOnTap(node.children[1])!) // dismiss from detail
        node = host.evaluate()
        #expect(node.children.count == 1)
    }

    @Test("Sheet appears as a hidden child only while presented")
    func sheet() {
        struct Screen: View {
            @State var shown = false
            var body: some View {
                Button("Show") { shown = true }
                    .sheet(isPresented: $shown) { Text("Sheet body") }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["hasSheet"] == nil)
        host.callbacks.invokeVoid(findOnTap(node)!)
        node = host.evaluate()
        #expect(node.props["hasSheet"] == .bool(true))
        #expect(node.children.contains { $0.type == "Sheet" })
    }

    @Test("Confirmation dialog presents its buttons and a chosen action dismisses it")
    func confirmationDialog() {
        struct Screen: View {
            @State var shown = false
            @State var picked = ""
            var body: some View {
                Button("Show") { shown = true }
                    .confirmationDialog("Manage", isPresented: $shown, titleVisibility: .visible, buttons: [
                        AlertButton("Duplicate") { picked = "dup" },
                        AlertButton("Delete", role: .destructive) { picked = "del" },
                    ])
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["hasConfirmationDialog"] == nil)
        host.callbacks.invokeVoid(findOnTap(node)!)
        node = host.evaluate()
        #expect(node.props["hasConfirmationDialog"] == .bool(true))
        let dialog = node.children.first { $0.type == "ConfirmationDialog" }
        #expect(dialog?.props["showsTitle"] == .bool(true))
        guard case .array(let buttons)? = dialog?.props["buttons"], buttons.count == 2 else {
            Issue.record("expected two buttons"); return
        }
        // second button (destructive) fires its action and dismisses the dialog
        guard case .array(let second) = buttons[1], case .string(let role) = second[1],
              case .int(let id) = second[2] else {
            Issue.record("malformed button"); return
        }
        #expect(role == "destructive")
        host.callbacks.invokeVoid(Int64(id))
        node = host.evaluate()
        #expect(node.props["hasConfirmationDialog"] == nil)   // dismissed
    }

    @Test("searchable surfaces a per-screen field whose input drives its binding")
    func searchable() {
        struct Screen: View {
            @State var query = ""
            var body: some View {
                NavigationStack {
                    Text("Results for \(query)")
                        .searchable(text: $query, prompt: "Find")
                }
            }
        }
        let host = ViewHost(Screen())
        let node = host.evaluate()
        #expect(node.type == "NavStack")
        guard case .array(let searches)? = node.props["searches"],
              case .array(let entry) = searches[0], entry.count == 3 else {
            Issue.record("expected a search descriptor for the root screen"); return
        }
        #expect(entry[0] == .string(""))          // current text
        #expect(entry[2] == .string("Find"))      // prompt
        guard case .int(let id) = entry[1] else {
            Issue.record("missing search callback id"); return
        }
        host.callbacks.invokeString(Int64(id), "abc")
        let updated = host.evaluate()
        guard case .array(let searches2)? = updated.props["searches"],
              case .array(let entry2) = searches2[0] else {
            Issue.record("missing search descriptor after input"); return
        }
        #expect(entry2[0] == .string("abc"))       // binding round-tripped
    }

    @Test("toolbar rides as placed hidden children whose buttons stay live")
    func toolbar() {
        struct Screen: View {
            @State var saved = 0
            var body: some View {
                Text("Body")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") { saved += 1 }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("Leading")
                        }
                        // a bare view is placed automatically
                        Text("Bare")
                    }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.props["hasToolbar"] == .bool(true))
        let items = node.children.filter { $0.type == "ToolbarItem" }
        #expect(items.count == 3)
        let placements = items.compactMap { item -> String? in
            guard case .string(let p)? = item.props["placement"] else { return nil }
            return p
        }
        #expect(placements == ["navigationBarTrailing", "navigationBarLeading", "automatic"])

        // the trailing item's button still dispatches into the screen's state
        guard let tap = findOnTap(items[0]) else {
            Issue.record("toolbar button lost its callback"); return
        }
        host.callbacks.invokeVoid(tap)
        node = host.evaluate()
        let label = node.children
            .filter { $0.type == "ToolbarItem" }
            .compactMap { firstTextString($0) }
            .first
        #expect(label == "Save")   // still rendered after the state change
        #expect(host.callbacks.callback(for: tap) != nil)
    }

    @Test("A sheet carries its detents, and none by default")
    func sheetDetents() {
        struct Screen: View {
            @State var shown = true
            var body: some View {
                Button("Show") { shown = true }
                    .sheet(isPresented: $shown) {
                        Text("body").presentationDetents([.medium])
                    }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        let sheet = node.children.first { $0.type == "Sheet" }
        #expect(sheet?.props["detents"] == .array([.string("medium")]))

        // no detents declared: the interpreter reads that as a full-height sheet
        struct Plain: View {
            @State var shown = true
            var body: some View {
                Button("Show") { shown = true }
                    .sheet(isPresented: $shown) { Text("body") }
            }
        }
        let plain = ViewHost(Plain()).evaluate()
        let plainSheet = plain.children.first { $0.type == "Sheet" }
        #expect(plainSheet?.props["detents"] == .array([]))
    }

    @Test("TabView emits tabs with their item labels and selection")
    func tabs() {
        struct Screen: View {
            @State var selection = 0
            var body: some View {
                TabView(selection: $selection) {
                    Text("One").tabItem { Text("First") }.tag(0)
                    Text("Two").tabItem { Text("Second") }.tag(1)
                }
            }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        #expect(node.type == "TabView")
        #expect(node.children.count == 2)
        #expect(node.props["selection"] == .int(0))
        // switching selection through the callback updates state
        if case .int(let id)? = node.props["onSelect"] {
            host.callbacks.invokeInt(Int64(id), 1)
        }
        node = host.evaluate()
        #expect(node.props["selection"] == .int(1))
    }
}

/// Finds the first `onTap` callback id anywhere in a node subtree.
private func findOnTap(_ node: RenderNode) -> Int64? {
    if case .int(let id)? = node.props["onTap"] { return Int64(id) }
    for child in node.children {
        if let id = findOnTap(child) { return id }
    }
    return nil
}
