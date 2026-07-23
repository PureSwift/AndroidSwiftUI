#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct GesturePlayground: View {

    @State private var dragX = 0.0
    @State private var dragY = 0.0
    @State private var dropped = "not yet"
    @State private var presses = 0
    @State private var taps = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("DragGesture") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Offset: \(Int(dragX)), \(Int(dragY))")
                        Text("Last drop: \(dropped)")
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue)
                            .frame(width: 90, height: 90)
                            .offset(x: dragX, y: dragY)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragX = value.translation.width
                                        dragY = value.translation.height
                                    }
                                    .onEnded { value in
                                        dropped = "\(Int(value.translation.width)), \(Int(value.translation.height))"
                                    }
                            )
                        Button("Reset") {
                            dragX = 0
                            dragY = 0
                        }
                    }
                }
                Example("onLongPressGesture") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Taps: \(taps)   Long presses: \(presses)")
                        Text("Tap or press and hold")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(8)
                            .onTapGesture { taps += 1 }
                            .onLongPressGesture { presses += 1 }
                    }
                }
            }
        }
    }
}
