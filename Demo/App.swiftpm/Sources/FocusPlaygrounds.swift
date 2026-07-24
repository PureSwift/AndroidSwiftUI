#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct FocusPlayground: View {

    private enum Field: Hashable { case name, email }

    @State private var name = ""
    @State private var email = ""
    @FocusState private var focus: Field?

    private var focusLabel: String {
        switch focus {
        case .name: return "Name"
        case .email: return "Email"
        case nil: return "none"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Focused field: \(focusLabel)")

                TextField("Name", text: $name)
                    .focused($focus, equals: .name)
                TextField("Email", text: $email)
                    .focused($focus, equals: .email)

                // driving focus from Swift
                Button("Focus name") { focus = .name }
                Button("Focus email") { focus = .email }
                Button("Dismiss keyboard") { focus = nil }
            }
            .padding()
        }
        .navigationTitle("FocusState")
    }
}
