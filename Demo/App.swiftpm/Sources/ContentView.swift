#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct ContentView: View {
    var body: some View {
        HStack {
            VStack(spacing: 20) {
                VStack {
                    
                    Image("globe")
                    
                    Text("Hello, world!")
                        .foregroundColor(.blue)
                        .bold()
                        .font(.title)
                }
                VStack {
                    HStack {
                        Image("heart.fill")
                        Text("Small")
                    }
                    HStack {
                        Image("heart.fill")
                        Text("Medium")
                    }
           
                    HStack {
                        Image("heart.fill")
                        Text("Large")
                   }
                }
            }
        }
    }
}
