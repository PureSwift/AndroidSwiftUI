//
//  LazyTests.swift
//  AndroidSwiftUICoreTests
//

import Testing
@testable import AndroidSwiftUICore

struct Item: Identifiable { let id: Int }

@Suite("Lazy containers")
struct LazyTests {

    @Test("List emits count and a provider, not inline rows")
    func listIsLazy() {
        struct Screen: View {
            var body: some View {
                List((1...1000).map(Item.init)) { Text("Row \($0.id)") }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.type == "List")
        #expect(node.count == 1000)
        #expect(node.children.isEmpty)   // rows are not materialized up front
        #expect(node.props["itemProvider"] != nil)
    }

    @Test("The item provider resolves a row subtree on demand")
    func providerResolvesRow() {
        struct Screen: View {
            var body: some View {
                List((1...100).map(Item.init)) { Text("Row \($0.id)") }
            }
        }
        let host = ViewHost(Screen())
        let node = host.evaluate()
        guard case .int(let providerID)? = node.props["itemProvider"] else {
            Issue.record("no provider"); return
        }
        // rows 0 and 42 resolve independently, only when asked
        let row0 = host.callbacks.item(Int64(providerID), 0)
        let row42 = host.callbacks.item(Int64(providerID), 42)
        #expect(row0?.props["text"] == .string("Row 1"))
        #expect(row42?.props["text"] == .string("Row 43"))
    }

    @Test("Row identity path is keyed by element id")
    func rowKeyedByIdentity() {
        struct Screen: View {
            let items: [Item]
            var body: some View { List(items) { Text("Row \($0.id)") } }
        }
        func rowID(_ items: [Item], index: Int) -> String {
            let host = ViewHost(Screen(items: items))
            let node = host.evaluate()
            guard case .int(let p)? = node.props["itemProvider"] else { return "" }
            return host.callbacks.item(Int64(p), index)?.id ?? ""
        }
        // element id 5 keeps its identity path whether it's at index 0 or 2
        let atIndex0 = rowID([Item(id: 5), Item(id: 6)], index: 0)
        let atIndex2 = rowID([Item(id: 3), Item(id: 4), Item(id: 5)], index: 2)
        #expect(atIndex0 == atIndex2)
    }

    @Test("refreshable attaches a refresh callback to the list")
    func refreshable() {
        struct Screen: View {
            var body: some View {
                List((1...3).map(Item.init)) { Text("Row \($0.id)") }
                    .refreshable { }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.props["onRefresh"] != nil)
    }

    @Test("LazyVGrid carries its track spec and resolves cells")
    func vgridFixed() {
        struct Screen: View {
            var body: some View {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(1...6, id: \.self) { Text("\($0)") }
                }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.type == "LazyVGrid")
        #expect(node.props["trackCount"] == .int(3))
        #expect(node.children.count == 6)
    }

    @Test("Adaptive grid carries a minimum column width")
    func vgridAdaptive() {
        struct Screen: View {
            var body: some View {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(1...4, id: \.self) { Text("\($0)") }
                }
            }
        }
        let node = ViewHost(Screen()).evaluate()
        #expect(node.props["adaptiveMin"] == .double(80))
        #expect(node.props["trackCount"] == nil)
    }
}
