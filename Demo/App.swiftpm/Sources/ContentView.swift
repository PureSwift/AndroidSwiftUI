#if canImport(SwiftAndroidUI)
import SwiftAndroidUI
#else
import SwiftUI
#endif

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Hello, world!")
                }
                VStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .imageScale(.small)
                            .foregroundColor(.red)
                        Text("Small")
                    }
                    HStack {
                        Image(systemName: "heart.fill")
                            .imageScale(.medium)
                            .foregroundColor(.red)
                        Text("Medium")
                    }
           
                    HStack {
                        Image(systemName: "heart.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                        Text("Large")
                   }
                }
                NavigationLink(destination: Text("Destination")) {
                    Text("Next")
                }
            }
            .navigationTitle("Demo")
        }
    }
}
