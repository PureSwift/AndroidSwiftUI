#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#elseif canImport(ComposeUI)
import SwiftUICore
#else
import SwiftUI
#endif

struct AnimationPlayground: View {
    @State private var moved = false
    @State private var faded = false
    @State private var grown = false
    @State private var recolored = false
    @State private var crawled = false
    @State private var showSlide = false
    @State private var showScale = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Transition: move + fade") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(showSlide ? "Remove" : "Insert") {
                            withAnimation { showSlide.toggle() }
                        }
                        if showSlide {
                            Text("I move in from the leading edge and fade")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .transition(.move(edge: .leading))
                        }
                    }
                }
                Example("Transition: scale") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(showScale ? "Remove" : "Insert") {
                            withAnimation(.spring()) { showScale.toggle() }
                        }
                        if showScale {
                            Text("I scale in and out")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(8)
                                .transition(.scale)
                        }
                    }
                }
                Example("withAnimation: offset") {
                    VStack(alignment: .leading, spacing: 8) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 44, height: 44)
                            .offset(x: moved ? 220 : 0, y: 0)
                        Button(moved ? "Slide back" : "Slide right") {
                            withAnimation { moved.toggle() }
                        }
                    }
                }
                Example("withAnimation: slow motion (2s linear)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(.red)
                            .frame(width: 44, height: 44)
                            .offset(x: crawled ? 220 : 0, y: 0)
                        Button(crawled ? "Crawl back" : "Crawl right") {
                            withAnimation(.linear(duration: 2)) { crawled.toggle() }
                        }
                    }
                }
                Example("withAnimation: opacity & scale") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Watch me")
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(8)
                            .opacity(faded ? 0.2 : 1)
                            .scaleEffect(faded ? 0.7 : 1)
                        Button(faded ? "Restore" : "Fade & shrink") {
                            withAnimation(.easeOut(duration: 0.6)) { faded.toggle() }
                        }
                    }
                }
                Example("withAnimation: spring frame") {
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green)
                            .frame(width: grown ? 260 : 90, height: 44)
                        Button(grown ? "Shrink" : "Grow") {
                            withAnimation(.spring()) { grown.toggle() }
                        }
                    }
                }
                Example(".animation(value:) implicit color") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Background eases on its own")
                            .padding()
                            .background(recolored ? Color.orange : Color.blue)
                            .cornerRadius(8)
                            .animation(.easeInOut(duration: 0.8), value: recolored)
                        Button("Swap color") { recolored.toggle() }
                    }
                }
            }
        }
    }
}
