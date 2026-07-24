#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct GeometryPlayground: View {

    @State private var tall = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("A GeometryReader reports the space its parent offers.")

            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 10) {
                    Text("Offered: \(Int(geometry.size.width)) × \(Int(geometry.size.height))")
                    // bars sized from the measurement — proof the number is live
                    Text("half width")
                    Rectangle()
                        .fill(.blue)
                        .frame(width: geometry.size.width / 2, height: 22)
                    Text("one quarter")
                    Rectangle()
                        .fill(.green)
                        .frame(width: geometry.size.width / 4, height: 22)
                }
            }
            .frame(height: tall ? 320 : 200)

            Button(tall ? "Shrink the reader" : "Grow the reader") { tall.toggle() }
        }
        .padding()
        .navigationTitle("GeometryReader")
    }
}
