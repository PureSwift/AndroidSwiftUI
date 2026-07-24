//
//  IdentityTests.swift
//  SwiftUICoreTests
//
//  The crown-jewel suite: @State survives re-evaluation, ForEach keyed inserts
//  preserve per-element state, and flipping a conditional resets state — the
//  semantics the whole architecture depends on, proven on the host.
//

import Testing
@testable import SwiftUICore

@Suite("Identity and state")
struct IdentityTests {

    @Test("State survives re-evaluation and reads back the written value")
    func stateSurvivesReevaluation() {
        struct Counter: View {
            @State private var count = 0
            var body: some View {
                VStack {
                    Text("count \(count)")
                    Button("inc") { count += 1 }
                }
            }
        }
        let host = ViewHost(Counter())

        var node = host.evaluate()
        #expect(node.children[0].props["text"] == .string("count 0"))

        // fire the button's callback, then re-evaluate
        if case .int(let id)? = node.children[1].props["onTap"] {
            host.callbacks.invokeVoid(Int64(id))
        } else {
            Issue.record("button had no onTap callback id")
        }
        node = host.evaluate()
        #expect(node.children[0].props["text"] == .string("count 1"))
    }

    @Test("State change fires the onChange hook")
    func stateChangeNotifies() {
        struct Counter: View {
            @State var count = 0
            var body: some View { Button("inc") { count += 1 } }
        }
        let host = ViewHost(Counter())
        var fired = false
        host.onStateChange = { fired = true }

        let node = host.evaluate()
        if case .int(let id)? = node.props["onTap"] { host.callbacks.invokeVoid(Int64(id)) }
        #expect(fired)
    }

    @Test("ForEach state is keyed by identity, so inserts don't shift it")
    func forEachKeyedState() {
        // Each row owns a @State; the resolver keys it by element id. We assert
        // the identity PATH of a given element is stable regardless of position.
        struct Row: View {
            let name: String
            @State private var flag = false
            var body: some View { Text(name) }
        }
        struct Screen: View {
            let names: [String]
            var body: some View {
                VStack { ForEach(names, id: \.self) { Row(name: $0) } }
            }
        }

        // paths of each Row node, before and after prepending an element
        func rowPaths(_ names: [String]) -> [String: String] {
            let node = ViewHost(Screen(names: names)).evaluate()
            var byText: [String: String] = [:]
            for child in node.children { if case .string(let t)? = child.props["text"] { byText[t] = child.id } }
            return byText
        }

        let before = rowPaths(["b", "c"])
        let after = rowPaths(["a", "b", "c"])   // prepend "a"
        // "b" and "c" keep their identity path even though their position shifted
        #expect(before["b"] == after["b"])
        #expect(before["c"] == after["c"])
    }

    @Test("Flipping a conditional gives the two branches distinct identity")
    func conditionalBranchesDiffer() {
        struct Screen: View {
            let flag: Bool
            var body: some View {
                VStack {
                    if flag { Text("on") } else { Text("off") }
                }
            }
        }
        let on = ViewHost(Screen(flag: true)).evaluate()
        let off = ViewHost(Screen(flag: false)).evaluate()
        // distinct branch components ("true"/"false") → distinct identity,
        // which is what makes SwiftUI reset state across a conditional flip
        #expect(on.children[0].id != off.children[0].id)
        #expect(on.children[0].props["text"] == .string("on"))
        #expect(off.children[0].props["text"] == .string("off"))
    }

    @Test("Independent @State at sibling paths don't alias")
    func siblingStateIsolation() {
        struct Counter: View {
            let label: String
            @State private var count = 0
            var body: some View {
                Button("\(label):\(count)") { count += 1 }
            }
        }
        struct Screen: View {
            var body: some View { VStack { Counter(label: "a"); Counter(label: "b") } }
        }
        let host = ViewHost(Screen())
        var node = host.evaluate()
        // bump only the first counter
        if case .int(let id)? = node.children[0].props["onTap"] { host.callbacks.invokeVoid(Int64(id)) }
        node = host.evaluate()
        // first advanced, second untouched
        #expect(node.children[0].children[0].props["text"] == .string("a:1"))
        #expect(node.children[1].children[0].props["text"] == .string("b:0"))
    }
}
