#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Lazy state initialization: the stored class is constructed once per view
/// lifetime, no matter how often the parent re-renders.
struct StateScreen: View {

    @State
    private var parentRenders = 0

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Parent re-renders: \(parentRenders)")
            Button("Re-render parent") {
                parentRenders += 1
            }
            Divider()
            StateChildView()
        }
    }
}

struct StateChildView: View {

    @State
    private var model = CountedModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Model instance: #\(model.instance)")
            Text(verbatim: "Total constructions: \(CountedModel.constructions)")
        }
    }
}

/// Counts how many times it has ever been constructed.
final class CountedModel {

    nonisolated(unsafe) static var constructions = 0

    let instance: Int

    init() {
        Self.constructions += 1
        instance = Self.constructions
    }
}
