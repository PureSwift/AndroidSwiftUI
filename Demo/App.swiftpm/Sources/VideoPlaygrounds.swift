#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
import AVKit
#endif

import Foundation

struct VideoPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Streaming video") {
                    VStack(alignment: .leading, spacing: 8) {
                        VideoPlayer(player: AVPlayer(url: URL(string: "https://storage.googleapis.com/exoplayer-test-media-0/BigBuckBunny_320x180.mp4")!))
                            .cornerRadius(8)
                        Text("Tap the video for playback controls")
                    }
                }
            }
        }
    }
}
