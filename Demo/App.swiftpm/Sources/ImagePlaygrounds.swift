#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct ImagePlayground: View {

    @State private var remoteIndex = 0

    private let remotes = [
        "https://www.gstatic.com/webp/gallery/1.jpg",
        "https://picsum.photos/id/237/300/200",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Asset image") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Image(\"sample_photo\") — natural size")
                        Image("sample_photo")
                    }
                }
                Example("resizable + scaledToFit") {
                    Image("sample_photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 90)
                }
                Example("resizable + scaledToFill") {
                    Image("sample_photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 90)
                }
                Example("AsyncImage") {
                    VStack(alignment: .leading, spacing: 8) {
                        AsyncImage(url: URL(string: remotes[remoteIndex]))
                            .frame(width: 200, height: 150)
                        Button("Load the other image") {
                            remoteIndex = (remoteIndex + 1) % remotes.count
                        }
                    }
                }
                Example("AsyncImage — failure") {
                    AsyncImage(url: URL(string: "https://example.invalid/missing.png"))
                        .frame(width: 200, height: 60)
                }
                Example("Unknown asset falls back") {
                    Image("no_such_asset")
                }
            }
        }
        .navigationTitle("Images")
    }
}
