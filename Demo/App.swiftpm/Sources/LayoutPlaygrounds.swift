#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct StackPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("VStack .leading") {
                    VStack(alignment: .leading) { Text("Row one"); Text("Row two, longer") }
                }
                Example("VStack .trailing") {
                    VStack(alignment: .trailing) { Text("Row one"); Text("Row two, longer") }
                }
                Example("HStack with Spacer") {
                    HStack { Text("Start"); Spacer(); Text("End") }
                }
                Example("ZStack .center") {
                    ZStack {
                        Color.blue.frame(width: 220, height: 100)
                        Text("Overlaid")
                    }
                }
                Example("ZStack .bottomTrailing") {
                    ZStack(alignment: .bottomTrailing) {
                        Color.green.frame(width: 220, height: 100)
                        Text("Corner")
                    }
                }
            }
        }
    }
}

struct SpacerDividerPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Spacer pushes apart") {
                    HStack { Text("Left"); Spacer(); Text("Right") }
                }
                Example("Divider between rows") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Above")
                        Divider()
                        Text("Below")
                    }
                }
            }
        }
    }
}

struct ColorPlayground: View {
    private let swatches: [(String, Color)] = [
        ("blue", .blue), ("green", .green), ("orange", .orange),
        ("purple", .purple), ("pink", .pink), ("red", .red),
        ("yellow", .yellow), ("gray", .gray),
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(swatches, id: \.0) { swatch in
                    Example(swatch.0) {
                        swatch.1.frame(height: 44).cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct ScrollViewPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Scroll to see all rows")
                    .padding()
                ForEach(1...40, id: \.self) { n in
                    Text("Scrollable row \(n)")
                        .padding()
                        .background(n % 2 == 0 ? Color.blue : Color.orange)
                        .cornerRadius(6)
                }
            }
        }
    }
}
