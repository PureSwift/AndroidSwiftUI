#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Sheet presentation, detents and the dismiss environment action.
struct SheetScreen: View {

    @State
    private var showsSheet = false

    @State
    private var showsDetentSheet = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Present sheet") {
                showsSheet = true
            }
            Button("Present medium detent sheet") {
                showsDetentSheet = true
            }
        }
        .sheet(isPresented: $showsSheet) {
            SheetContent(title: "Full size sheet")
        }
        .sheet(isPresented: $showsDetentSheet) {
            SheetContent(title: "Medium sheet")
                .presentationDetents([.medium])
        }
    }
}

struct SheetContent: View {

    let title: String

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
            Button("Dismiss") {
                dismiss()
            }
        }
    }
}
