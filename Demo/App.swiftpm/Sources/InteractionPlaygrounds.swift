#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct InteractionPlayground: View {
    @State private var taps = 0
    @State private var appearances = 0
    @State private var slider = 0.0
    @State private var sliderChanges = 0
    @State private var blocked = true
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("onTapGesture") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tapped \(taps) time(s)")
                        Text("Tap this row")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .onTapGesture { taps += 1 }
                    }
                }
                Example("onAppear") {
                    Text("This row appeared \(appearances) time(s)")
                        .onAppear { appearances += 1 }
                }
                Example("onChange") {
                    VStack(alignment: .leading, spacing: 8) {
                        Slider(value: $slider, in: 0...1)
                        Text("Slider changed \(sliderChanges) time(s)")
                    }
                    .onChange(of: slider) { sliderChanges += 1 }
                }
                Example("disabled") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(blocked ? "Disabled button" : "Enabled button") { taps += 1 }
                            .disabled(blocked)
                        Button("Toggle disabled") { blocked.toggle() }
                    }
                }
            }
        }
    }
}
