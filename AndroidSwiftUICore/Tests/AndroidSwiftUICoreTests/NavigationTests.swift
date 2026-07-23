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
