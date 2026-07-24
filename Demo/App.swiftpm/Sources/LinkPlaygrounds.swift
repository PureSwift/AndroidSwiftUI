#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct LinkPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Link with a title") {
                    Link("Open swift.org", destination: URL(string: "https://swift.org")!)
                }
                Example("Link with a custom label") {
                    Link(destination: URL(string: "https://developer.apple.com/documentation/swiftui")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                            Text("SwiftUI documentation")
                        }
                    }
                }
                Example("Link inside a sentence") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Questions? The forums are a good place to start.")
                        Link("forums.swift.org", destination: URL(string: "https://forums.swift.org")!)
                    }
                }
            }
        }
        .navigationTitle("Link")
    }
}
