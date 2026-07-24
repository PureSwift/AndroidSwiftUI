#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
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
                Example("Unknown modifier → red outline") {
                    Text("Carries a modifier the interpreter doesn't recognize")
                        .padding()
                        .unrecognizedModifier()
                }
            }
        }
    }
}

/// A stand-in for a modifier the interpreter has no fold for — emits a kind
/// outside the known set, so the renderer flags it with a red outline.
struct _UnrecognizedModifier: RenderModifier {
    var _modifierNode: ModifierNode { ModifierNode(kind: "notImplementedInInterpreter") }
}

extension View {
    func unrecognizedModifier() -> ModifiedContent<Self, _UnrecognizedModifier> {
        modifier(_UnrecognizedModifier())
    }
}
