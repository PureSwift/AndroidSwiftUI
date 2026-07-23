#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct ListPlayground: View {
    @State private var rows = (1...25).map(CatalogRow.init)
    var body: some View {
        List(rows) { row in
            Text(row.title)
        }
        .refreshable {
            try? await Task.sleep(for: .seconds(1))
            rows.insert(CatalogRow(id: rows.count + 1), at: 0)
        }
    }
}

struct CatalogRow: Identifiable {
    let id: Int
    var title: String { "Row \(id)" }
}

struct GridPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Three fixed columns") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(1...9, id: \.self) { n in
                            Text("\(n)").padding().background(Color.blue).cornerRadius(6)
                        }
                    }
                }
                Example("Adaptive columns") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(1...8, id: \.self) { n in
                            Text("Item \(n)").padding().background(Color.orange).cornerRadius(6)
                        }
                    }
                }
                Example("Two rows, horizontal") {
                    LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(1...8, id: \.self) { n in
                            Text("Cell \(n)").padding().background(Color.green).cornerRadius(6)
                        }
                    }
                    .frame(height: 160)
                }
            }
        }
    }
}

struct ModifierPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Padding") { Text("Padded").padding().background(Color.blue) }
                Example("Frame 200x60") { Text("Fixed").frame(width: 200, height: 60).background(Color.green) }
                Example("Background") { Text("Colored").padding().background(Color.orange) }
                Example("Corner radius") { Text("Rounded").padding().background(Color.purple).cornerRadius(16) }
                Example("Offset") { Text("Shifted").offset(x: 30, y: 0).background(Color.red) }
                Example("Rotation") { Text("Rotated").padding().background(Color.yellow).rotationEffect(.degrees(15)) }
                Example("Scale") { Text("Scaled").padding().background(Color.pink).scaleEffect(1.4) }
                Example("Opacity") { Text("Faded").padding().background(Color.blue).opacity(0.4) }
            }
        }
    }
}
