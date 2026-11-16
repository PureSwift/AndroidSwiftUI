import Testing
@testable import SwiftUICore

@Suite("Preferred color scheme")
struct ColorSchemeTests {
    @Test("A picker switches between system, light and dark without changing identity")
    func switching() throws {
        struct Screen: View {
            @State var appearance = "system"
            var body: some View {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .preferredColorScheme(ColorScheme(rawValue: appearance))
            }
        }
        let host = ViewHost(Screen())
        let initial = host.evaluate()
        #expect(initial.modifiers.first?.kind == "preferredColorScheme")
        #expect(initial.modifiers.first?.args.isEmpty == true)
        let callback = try #require(initial.props["onChange"])
        guard case .int(let id) = callback else { Issue.record("Missing callback"); return }
        for appearance in ["dark", "light", "system"] {
            host.callbacks.invokeString(Int64(id), appearance)
            let node: RenderNode
            switch host.evaluateUpdate() {
            case .full(let tree): node = tree
            case .patch(_, let subtree): node = subtree
            }
            #expect(node.id == initial.id)
            #expect(node.props["selection"] == .string(appearance))
            let expected: PropValue? = appearance == "system" ? nil : .string(appearance)
            #expect(node.modifiers.first?.args["colorScheme"] == expected)
        }
    }
}
