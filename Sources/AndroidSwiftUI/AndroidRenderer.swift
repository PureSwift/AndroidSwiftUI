//
//  AndroidRenderer.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

import JavaKit
import AndroidKit
import Dispatch

final class AndroidRenderer: Renderer {
        
    let configuration: _AppConfiguration
    
    private(set) var reconciler: StackReconciler<AndroidRenderer>!
    
    static var shared: AndroidRenderer!
    
    init(app: any App, configuration: _AppConfiguration) {
        self.configuration = configuration
        self.reconciler = StackReconciler(
            app: app,
            target: AndroidTarget.application,
            environment: .defaultEnvironment, // merge environment with scene environment
            renderer: self, // FIXME: Always retained
            scheduler: { next in
                DispatchQueue.main.async {
                    next()
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
        if let anyView = mapAnyView( host.view, transform: { (component: AnyAndroidView) in component }) {
            switch parent.storage {
            case .application:
                // root view, add to main activity
                let viewObject = anyView.createAndroidView()
                return AndroidTarget(host.view, viewObject)
            case .view(let parentView):
                // subview add to parent
                guard parentView.is(ViewGroup.self) else {
                    return nil
                }
                let viewObject = anyView.createAndroidView()
                return AndroidTarget(host.view, viewObject)
            }
        } else {
            
            // handle cases like `TupleView`
            if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
                return parent
            }
            
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
        guard let widget = mapAnyView(host.view, transform: { (widget: AnyAndroidView) in widget })
            else { return }

        //widget.update(target.javaObject)
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
