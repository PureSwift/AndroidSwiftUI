#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct PopoverPlayground: View {

    @State private var infoShown = false
    @State private var chooserShown = false
    @State private var picked = "nothing"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Info popover") {
                    Button("Show details") { infoShown = true }
                        .popover(isPresented: $infoShown) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quick details")
                                Text("This bubble is anchored to the button.")
                                Button("Got it") { infoShown = false }
                            }
                        }
                }
                Example("Popover that reports a choice") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Picked: \(picked)")
                        Button("Choose") { chooserShown = true }
                            .popover(isPresented: $chooserShown) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Button("Option A") { picked = "A"; chooserShown = false }
                                    Button("Option B") { picked = "B"; chooserShown = false }
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Popover")
    }
}
