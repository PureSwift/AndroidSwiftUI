#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct LazyStackPlayground: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LazyHStack — 500 items")
            LazyHStack(spacing: 8) {
                ForEach(0..<500, id: \.self) { index in
                    Text("\(index)")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(6)
                }
            }
            .frame(height: 64)

            Text("LazyVStack — 10,000 rows")
            // The ScrollView hands scrolling to the lazy stack, which only
            // materializes the rows on screen.
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<10_000, id: \.self) { index in
                        Text("Row \(index)")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Lazy Stacks")
    }
}
