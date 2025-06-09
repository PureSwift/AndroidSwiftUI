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
        guard let resource = try? ImageCache.shared.load(imageName) else {
            assertionFailure()
            return
        }
        // set the image on the view
        view.setImageResource(resource)
    }
}

final class ImageCache {
    
    static let shared = ImageCache()
    
    private init() { }
    
    let drawable = AndroidR.R.drawable()
    
    private(set) var images: [String: Int32] = [:]
    
    func load(_ imageName: String) throws -> Int32 {
        // return cached resource ID
        if let resource = images[imageName] {
            return resource
        }
        // try to get resource
        let resource = try drawable.dynamicJavaMethodCall(methodName: imageName, resultType: Int32.self)
        // cache value
        images[imageName] = resource
        return resource
    }
}
