//
//  ImageView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension Image: AnyAndroidView {
    
    func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createView(context: context)
    }
    
    func updateAndroidView() {
        
    }
    
    func removeAndroidView() {
        
    }
}

extension Image {
    
    func createView(context: AndroidContent.Context) -> ImageView {
        let view = ImageView(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: ImageView) {
        let proxy = _ImageProxy(self)
        let image = proxy.provider.resolve(in: proxy.environment)
        guard case let .named(imageName, _) = image.storage else {
            assertionFailure()
            return
        }
        guard let resource = ImageCache.shared.load(imageName) else {
            return
        }
        // set the image on the view
        view.setImageResource(resource)
    }
}

final class ImageCache {
    
    static let shared = ImageCache()
    
    private init() { }
    
    let resources = Resources()
        
    private(set) var images: [String: Int32] = [:]
    
    func load(_ imageName: String) -> Int32? {
        log("\(self).\(#function) load '\(imageName)'")
        // return cached resource ID
        if let resource = images[imageName] {
            log("\(self).\(#function) Return cached resource ID \(resource) for '\(imageName)'")
            return resource
        }
        // try to get resource
        
        guard let resource = identifier(for: imageName) else {
            log("\(self).\(#function) Resource not found for '\(imageName)'")
            return nil
        }
        log("\(self).\(#function) Found resource ID \(resource) for '\(imageName)'")
        // cache value
        images[imageName] = resource
        return resource
    }
    
    private func identifier(for name: String) -> Int32? {
        let resource = resources.getIdentifier(name, "drawable", "com.pureswift.swiftandroid")
        guard resource != 0 else {
            return nil
        }
        return resource
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
