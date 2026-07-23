#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct AppearancePlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Border") {
                    Text("Bordered")
                        .padding()
                        .border(.blue, width: 2)
                }
                Example("Shadow") {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .frame(width: 140, height: 64)
                        .shadow(radius: 10)
                }
                Example("Clip to circle") {
                    Color.blue.frame(width: 80, height: 80).clipShape(Circle())
                }
                Example("Clip to capsule") {
                    Text("Capsule")
                        .padding()
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
                Example("Overlay badge") {
                    Color.blue
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .overlay(alignment: .bottomTrailing) {
                            Circle().fill(.red).frame(width: 26, height: 26)
                        }
                }
                Example("Overlay text") {
                    Color.green
                        .frame(height: 80)
                        .cornerRadius(8)
                        .overlay {
                            Text("Centered overlay").foregroundColor(.white).bold()
                        }
                }
            }
        }
    }
}
