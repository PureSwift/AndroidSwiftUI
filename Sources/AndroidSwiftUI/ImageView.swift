//
//  ImageView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/9/25.
//

import AndroidKit

extension Image: AnyAndroidView {
    
    public func createAndroidView(_ context: AndroidContent.Context) -> AndroidView.View {
        createImageView(context: context)
    }
    
    public func updateAndroidView(_ view: AndroidView.View) {
        guard let imageView = view.as(ImageView.self) else {
            assertionFailure()
            return
        }
        updateImageView(imageView)
    }
    
    public func removeAndroidView() {
        
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

public struct AndroidImageView {
    
    /// Underlying Image
    let image: Image
    
    /// The alpha value that should be applied to the image (between 0 and 255 inclusive, with 0 being transparent and 255 being opaque)
    let alpha: Int32
    
    public init(_ imageName: String, alpha: Int32 = 255) {
        self.image = .named(imageName)
        self.alpha = alpha
    }
    
    public init(resource: ResourceID, alpha: Int32 = 255) {
        self.image = .resource(resource)
        self.alpha = alpha
    }
    
    public init(url: URL, alpha: Int32 = 255) {
        self.image = .url(url)
        self.alpha = alpha
    }
    
    public init(bitmap: AndroidGraphics.Bitmap, alpha: Int32 = 255) {
        self.image = .bitmap(bitmap)
        self.alpha = alpha
    }
}

internal extension AndroidImageView {
    
    enum Image {
        
        case named(String)
        case resource(ResourceID)
        case url(URL)
        case bitmap(AndroidGraphics.Bitmap)
    }
}

extension AndroidImageView: AndroidViewRepresentable {
    
    public typealias Coordinator = Void
    
    /// Creates the view object and configures its initial state.
    public func makeAndroidView(context: Self.Context) -> AndroidWidget.ImageView {
        let view = AndroidWidget.ImageView(context.androidContext)
        updateView(view)
        return view
    }
    
    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateAndroidView(_ view: AndroidWidget.ImageView, context: Self.Context) {
        updateView(view)
    }
}

extension AndroidImageView {
    
    func createView(context: AndroidContent.Context) -> AndroidWidget.ImageView {
        let view = AndroidWidget.ImageView(context)
        updateView(view)
        return view
    }
    
    func updateView(_ view: AndroidWidget.ImageView) {
        // set alpha
        view.setAlpha(alpha)
        // set image content
        switch image {
        case let .named(imageName):
            guard let resource = ImageCache.shared.load(imageName, context: view.getContext()) else {
                return
            }
            view.setImageResource(resource)
        case let .resource(resource):
            view.setImageResource(resource)
        case let .url(url):
            fatalError("setImageURI not implemented")
        case let .bitmap(bitmap):
            fatalError("setImageBitmap not implemented")
        }
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
