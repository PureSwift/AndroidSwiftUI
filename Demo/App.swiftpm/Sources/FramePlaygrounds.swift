#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct FramePlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("maxWidth: .infinity") {
                    Text("Fills the width")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                }
                Example("Fill, leading-aligned content") {
                    Text("Left")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.green)
                }
                Example("Fill, trailing-aligned content") {
                    Text("Right")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                        .background(Color.orange)
                }
                Example("Fixed 220x90, bottom-trailing content") {
                    Text("corner")
                        .foregroundColor(.white)
                        .frame(width: 220, height: 90, alignment: .bottomTrailing)
                        .background(Color.purple)
                }
                Example("Bounded width (min 120, max 200)") {
                    Text("Bounded box grows to fit within limits")
                        .padding()
                        .frame(minWidth: 120, maxWidth: 200)
                        .background(Color.pink)
                }
            }
        }
    }
}
