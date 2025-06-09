//
//  ImageView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension Image: AnyAndroidView {
    
    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createImageView(context: context)
    }
    
    func updateAndroidView(_ view: AndroidView.View) {
        guard let imageView = view.as(ImageView.self) else {
            assertionFailure()
            return
        }
        updateImageView(imageView)
    }
    
    func removeAndroidView() {
        
    }
}

extension Image {
    
    func createImageView(context: AndroidContent.Context) -> ImageView {
        let view = ImageView(context)
        updateImageView(view)
        return view
    }
    
    func updateImageView(_ view: ImageView) {
        let proxy = _ImageProxy(self)
        let image = proxy.provider.resolve(in: proxy.environment)
        guard case let .named(imageName, _) = image.storage else {
            assertionFailure()
            return
        }
        guard let resource = ImageCache.shared.load(imageName, context: view.getContext()) else {
            return
        }
        // set the image on the view
        view.setImageResource(resource)
    }
}

final class ImageCache {
    
    static let shared = ImageCache()
    
    private init() { }
    
    private(set) var imageResources: [String: ResourceID] = [:]
    
    func load(_ imageName: String, context: AndroidContent.Context) -> ResourceID? {
        log("\(self).\(#function) load '\(imageName)'")
        // return cached resource ID
        if let resource = imageResources[imageName] {
            log("\(self).\(#function) Return cached resource ID \(resource) for '\(imageName)'")
            return resource
        }
        // try to get resource
        guard let resource = ResourceID.drawable(imageName, in: context) else {
            log("\(self).\(#function) Resource not found for '\(imageName)'")
            return nil
        }
        log("\(self).\(#function) Found resource ID \(resource) for '\(imageName)'")
        // cache value
        imageResources[imageName] = resource
        return resource
    }
}

internal extension ResourceID {
    
    static func drawable(
        _ name: String,
        in context: AndroidContent.Context
    ) -> ResourceID? {
        ResourceID(name: name, type: "drawable", in: context)
    }
}

private extension Image {
    
    static var logTag: String { "Image" }
    
    static func log(_ string: String) {
        let log = try! JavaClass<AndroidUtil.Log>()
        _ = log.d(Self.logTag, string)
    }
}

private extension ImageCache {
    
    func log(_ string: String) {
        Image.log(string)
    }
}
