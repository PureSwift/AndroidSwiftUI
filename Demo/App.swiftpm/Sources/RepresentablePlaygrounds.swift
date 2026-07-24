#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct RepresentablePlayground: View {
    @State private var stars = 3.5
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Native RatingBar (two-way)") {
                    VStack(alignment: .leading, spacing: 8) {
                        ComposableView(
                            "RatingBar",
                            props: ["rating": .double(stars), "max": 5],
                            actions: ["onRatingChanged": .double { stars = $0 }]
                        )
                        .frame(height: 60)
                        HStack {
                            Button("−½") { stars = max(0, stars - 0.5) }
                            Button("+½") { stars = min(5, stars + 0.5) }
                            Text("\(stars) / 5")
                        }
                        Text("Drag the stars or use the buttons — both drive the same state.")
                    }
                }
                Example("Compose function with SwiftUI children") {
                    ComposableView("DashedBorder", props: ["color": .color(.blue)]) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("These SwiftUI views").bold()
                            Text("sit inside a Compose-drawn dashed border.")
                        }
                    }
                }
                Example("Unregistered name (diagnostic)") {
                    ComposableView("DoesNotExist")
                        .frame(height: 40)
                }
            }
        }
    }
}
