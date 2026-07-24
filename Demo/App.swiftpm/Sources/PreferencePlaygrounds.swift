#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

/// Keeps the largest value any descendant published.
struct WidestKey: PreferenceKey {
    static var defaultValue: Double { 0 }
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = max(value, nextValue())
    }
}

/// Gathers every descendant's label, in tree order.
struct RowNamesKey: PreferenceKey {
    static var defaultValue: [String] { [] }
    static func reduce(value: inout [String], nextValue: () -> [String]) {
        value += nextValue()
    }
}

struct PreferencePlayground: View {

    @State private var rows = 3
    @State private var widest = 0.0
    @State private var names: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Children publish values; an ancestor reads them reduced.")

            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<rows, id: \.self) { index in
                    Text("row \(index) publishes \((index + 1) * 30)")
                        .preference(key: WidestKey.self, value: Double((index + 1) * 30))
                        .preference(key: RowNamesKey.self, value: ["row \(index)"])
                }
            }
            .onPreferenceChange(WidestKey.self) { widest = $0 }
            .onPreferenceChange(RowNamesKey.self) { names = $0 }

            Divider()
            Text("Largest published: \(Int(widest))")
            Text("Collected: \(names.joined(separator: ", "))")

            Button("Add a row") { rows += 1 }
            Button("Remove a row") { if rows > 1 { rows -= 1 } }
        }
        .padding()
        .navigationTitle("Preferences")
    }
}
