#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct GraphicsPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Shapes") {
                    HStack(spacing: 12) {
                        Rectangle().fill(.blue).frame(width: 60, height: 60)
                        Circle().fill(.green).frame(width: 60, height: 60)
                        Capsule().fill(.orange).frame(width: 90, height: 40)
                        RoundedRectangle(cornerRadius: 12).fill(.purple).frame(width: 60, height: 60)
                    }
                }
                Example("Linear gradient (horizontal)") {
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        .frame(height: 60)
                        .cornerRadius(8)
                }
                Example("Linear gradient (vertical)") {
                    LinearGradient(colors: [.orange, .red, .pink], startPoint: .top, endPoint: .bottom)
                        .frame(height: 80)
                        .cornerRadius(8)
                }
                Example("SF Symbols") {
                    HStack(spacing: 16) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Image(systemName: "heart.fill").foregroundColor(.red)
                        Image(systemName: "trash").foregroundColor(.gray)
                        Image(systemName: "gear")
                        Image(systemName: "bell.fill").foregroundColor(.blue)
                    }
                }
                Example("Symbols sized") {
                    HStack(spacing: 16) {
                        Image(systemName: "star.fill").frame(width: 40, height: 40).foregroundColor(.orange)
                        Image(systemName: "cart.fill").frame(width: 40, height: 40).foregroundColor(.green)
                        Image(systemName: "person.fill").frame(width: 40, height: 40).foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
