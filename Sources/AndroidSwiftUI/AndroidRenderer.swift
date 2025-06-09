//
//  AndroidRenderer.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import JavaKit
import AndroidKit

final class AndroidRenderer: Renderer {
        
    let configuration: _AppConfiguration
    
    private(set) var reconciler: StackReconciler<AndroidRenderer>!
    
    static var shared: AndroidRenderer!
    
    init(app: any App, configuration: _AppConfiguration) {
        Self.log("\(Self.self).\(#function)")
        self.configuration = configuration
        self.reconciler = StackReconciler(
            app: app,
            target: AndroidTarget.application,
            environment: .defaultEnvironment, // merge environment with scene environment
            renderer: self, // FIXME: Always retained
            scheduler: { next in
                Task {
                    await MainActor.run {
                        Self.log("\(self).\(#function) Scheduling next view update")
                        next()
                    }
                }
            }
        )
    }
    
    /** Function called by a reconciler when a new target instance should be
     created and added to the parent (either as a subview or some other way, e.g.
     installed if it's a layout constraint).
     - parameter parent: Parent target that will own a newly created target instance.
     - parameter view: The host view that renders to the newly created target.
     - returns: The newly created target.
     */
    func mountTarget(
      before sibling: AndroidTarget?,
      to parent: AndroidTarget,
      with host: MountedHost
    ) -> TargetType? {
        log("\(self).\(#function) Host \(host.view.typeConstructorName) Parent \(parent.storage)")
        guard let activity = MainActivity.shared else {
            logError("MainActivity.shared != nil")
            return nil
        }
        let context = activity as AndroidContent.Context
        if let anyView = mapAnyView( host.view, transform: { (component: AnyAndroidView) in component }) {
            log("\(self).\(#function) \(#line)")
            switch parent.storage {
            case .application:
                // root view, add to main activity
                let viewObject = anyView.createAndroidView(context)
                activity.setRootView(viewObject)
                log("\(self).\(#function) \(#line): Created root view \(viewObject.getClass().getName())")
                return AndroidTarget(host.view, viewObject)
            case .view(let parentView):
                // subview add to parent
                log("\(self).\(#function) \(#line)")
                guard parentView.is(ViewGroup.self), let viewGroup = parentView.as(ViewGroup.self) else {
                    logError("\(self).\(#function) \(#line) Parent View \(parentView.getClass().getName()) is not a ViewGroup)")
                    return nil
                }
                let viewObject = anyView.createAndroidView(context)
                // TODO: Determine order
                viewGroup.addView(viewObject)
                log("\(self).\(#function) \(#line): Add \(viewObject.getClass().getName()) to \(viewGroup.getClass().getName())")
                return AndroidTarget(host.view, viewObject)
            }
        } else {
            
            // handle cases like `TupleView`
            if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
                log("\(self).\(#function) \(#line)")
                return parent
            }
            log("\(self).\(#function) \(#line)")
            return nil
        }
    }
    
    /** Function called by a reconciler when an existing target instance should be
     updated.
     - parameter target: Existing target instance to be updated.
     - parameter view: The host view that renders to the updated target.
     */
    func update(
      target: AndroidTarget,
      with host: MountedHost
    ) {
        log("\(self).\(#function) \(host.view.typeConstructorName)")
        guard let widget = mapAnyView(host.view, transform: { (widget: AnyAndroidView) in widget })
            else { return }
        
        switch target.storage {
        case .application:
            break
        case .view(let view):
            log("\(self).\(#function) Update \(view.getClass().getName())")
            widget.updateAndroidView(view)
        }
    }

    /** Function called by a reconciler when an existing target instance should be
     unmounted: removed from the parent and most likely destroyed.
     - parameter target: Existing target instance to be unmounted.
     - parameter parent: Parent of target to direct interaction with parent.
     - parameter task: The state associated with the unmount.
     */
    func unmount(
      target: AndroidTarget,
      from parent: AndroidTarget,
      with task: UnmountHostTask<AndroidRenderer>
    ) {
        log("\(self).\(#function)")
        defer { task.finish() }
        
        guard mapAnyView(task.host.view, transform: { (widget: AnyAndroidView) in widget }) != nil
        else { return }

        target.destroy()
    }
    
    /** Returns a body of a given pritimive view, or `nil` if `view` is not a primitive view for
     this renderer.
     */
    func primitiveBody(for view: Any) -> AnyView? {
        (view as? AndroidPrimitive)?.renderedBody
    }

    /** Returns `true` if a given view type is a primitive view that should be deferred to this
     renderer.
     */
    func isPrimitiveView(_ type: Any.Type) -> Bool {
        type is AndroidPrimitive.Type
    }
}

private extension AndroidRenderer {
    
    static var logTag: String { "AndroidRenderer" }
    
    static let log = try! JavaClass<AndroidUtil.Log>()
    
    static func log(_ string: String) {
        _ = Self.log.d(Self.logTag, string)
    }
    
    static func logError(_ string: String) {
        _ = Self.log.e(Self.logTag, string)
    }
    
    func log(_ string: String) {
        Self.log(string)
    }
    
    func logError(_ string: String) {
        Self.logError(string)
    }
}
