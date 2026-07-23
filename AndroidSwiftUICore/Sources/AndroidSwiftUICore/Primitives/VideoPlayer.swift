//
//  VideoPlayer.swift
//  AndroidSwiftUICore
//
//  A video player with system playback controls. The node carries the media
//  URL; the Android interpreter hosts a platform player view, and the desktop
//  rig shows a placeholder.
//

import Foundation

/// A playable media item. Mirrors the AVKit spelling; only URL-backed
/// playback is modeled.
public struct AVPlayer: Sendable {
    public var url: URL
    public init(url: URL) { self.url = url }
}

public struct VideoPlayer: View {

    internal let player: AVPlayer

    public init(player: AVPlayer) {
        self.player = player
    }

    public typealias Body = Never
}

extension VideoPlayer: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        RenderNode(
            type: "VideoPlayer",
            id: context.path,
            props: ["url": .string(player.url.absoluteString)]
        )
    }
}
