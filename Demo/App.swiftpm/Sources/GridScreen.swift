#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// Lazy grids.
struct GridScreen: View {

    var body: some View {
        VStack(spacing: 16) {
            Text("Three fixed columns")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(1...9, id: \.self) { number in
                    Text("\(number)")
                        .padding()
                        .background(Color.blue)
                }
            }
            Divider()
            Text("Adaptive columns")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                ForEach(1...8, id: \.self) { number in
                    Text("Item \(number)")
                        .padding()
                        .background(Color.orange)
                }
            }
            Divider()
            Text("Two rows, horizontal")
            LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(1...8, id: \.self) { number in
                    Text("Cell \(number)")
                        .padding()
                        .background(Color.green)
                }
            }
            .frame(height: 160)
        }
    }
}
