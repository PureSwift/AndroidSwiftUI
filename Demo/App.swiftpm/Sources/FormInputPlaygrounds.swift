#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct FormInputPlayground: View {

    @State private var amount = ""
    @State private var email = ""
    @State private var query = ""
    @State private var submissions = 0
    @State private var lastSubmitted = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("keyboardType(.decimalPad)") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Example("keyboardType(.emailAddress)") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                Example("submitLabel(.search) + onSubmit") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Search", text: $query)
                            .submitLabel(.search)
                            .onSubmit {
                                submissions += 1
                                lastSubmitted = query
                            }
                        Text("Submitted \(submissions) time(s)")
                        Text("Last: \(lastSubmitted)")
                    }
                }
            }
        }
        .navigationTitle("Form Input")
    }
}
