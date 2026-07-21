//
//  AndroidRenderer.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 6/8/25.
//

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
                // Post to the Android main looper. A Swift Concurrency task is not reliably
                // executed when scheduled from every JNI entry point (e.g. the Compose back
                // handler), so schedule through the platform run loop instead.
                let runnable = Runnable {
                    next()
                }
                _ = Self.mainHandler.post(runnable.as(JavaLang.Runnable.self))
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
        RepresentableHostContext.update(host)
        if let anyView = mapAnyView( host.view, transform: { (component: AnyAndroidView) in component }) {
            log("\(self).\(#function) \(#line)")
            switch parent.storage {
            case .application:
                // root view, add to main activity
                let viewObject = anyView.createAndroidView(context)
                // inset the content from the system bars when drawing edge to edge
                viewObject.setFitsSystemWindows(true)
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
                if let transitioning = mapAnyView(host.view, transform: { (view: AndroidTransitioningView) in view }) {
                    transitioning.transition.animateAppearance(of: viewObject)
                }
                log("\(self).\(#function) \(#line): Add \(viewObject.getClass().getName()) to \(viewGroup.getClass().getName())")
                return AndroidTarget(host.view, viewObject)
            case .fragment, .androidXFragment:
                logError("\(self).\(#function) \(#line) Mounting views inside fragments is not supported")
                return nil
            }
        } else if let anyFragment = mapAnyView(host.view, transform: { (component: AnyAndroidFragment) in component }) {
            guard let container = mountFragmentContainer(to: parent, context: context, activity: activity) else {
                return nil
            }
            let fragment = anyFragment.createFragment(context)
            guard let transaction = activity.getFragmentManager()?.beginTransaction() else {
                logError("\(self).\(#function) \(#line) Unable to begin fragment transaction")
                return nil
            }
            _ = transaction.add(container.getId(), fragment)
            _ = transaction.commit()
            log("\(self).\(#function) \(#line): Added \(fragment.getClass().getName()) to container \(container.getId())")
            return AndroidTarget(host.view, fragment, container: container)
        } else if let anyFragment = mapAnyView(host.view, transform: { (component: AnyAndroidXFragment) in component }) {
            guard let fragmentActivity = activity.as(AndroidXFragmentActivity.self) else {
                logError("\(self).\(#function) \(#line) \(activity.getClass().getName()) is not a FragmentActivity")
                return nil
            }
            guard let container = mountFragmentContainer(to: parent, context: context, activity: activity) else {
                return nil
            }
            let fragment = anyFragment.createAndroidXFragment(context)
            guard let transaction = fragmentActivity.getSupportFragmentManager()?.beginTransaction() else {
                logError("\(self).\(#function) \(#line) Unable to begin fragment transaction")
                return nil
            }
            _ = transaction.add(container.getId(), fragment)
            _ = transaction.commit()
            log("\(self).\(#function) \(#line): Added \(fragment.getClass().getName()) to container \(container.getId())")
            return AndroidTarget(host.view, fragment, container: container)
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
        RepresentableHostContext.update(host)
        switch target.storage {
        case .application:
            break
        case .view(let view):
            guard let widget = mapAnyView(host.view, transform: { (widget: AnyAndroidView) in widget })
                else { return }
            log("\(self).\(#function) Update \(view.getClass().getName())")
            widget.updateAndroidView(view)
        case .fragment(let fragment, _):
            guard let widget = mapAnyView(host.view, transform: { (widget: AnyAndroidFragment) in widget })
                else { return }
            log("\(self).\(#function) Update \(fragment.getClass().getName())")
            widget.updateFragment(fragment)
        case .androidXFragment(let fragment, _):
            guard let widget = mapAnyView(host.view, transform: { (widget: AnyAndroidXFragment) in widget })
                else { return }
            log("\(self).\(#function) Update \(fragment.getClass().getName())")
            widget.updateAndroidXFragment(fragment)
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
        RepresentableHostContext.update(task.host)
        switch target.storage {
        case .application:
            task.finish()
            return
        case .view(let view):
            guard let widget = mapAnyView(task.host.view, transform: { (widget: AnyAndroidView) in widget })
            else {
                task.finish()
                return
            }
            widget.removeAndroidView(view)
            // animate the view out before removing it; children stay mounted until
            // the unmount task finishes, so the content remains visible while animating
            if let transitioning = mapAnyView(task.host.view, transform: { (view: AndroidTransitioningView) in view }),
               transitioning.transition != .none {
                transitioning.transition.animateRemoval(of: view) {
                    target.destroy()
                    task.finish()
                }
                return
            }
        case .fragment(let fragment, _):
            guard let widget = mapAnyView(task.host.view, transform: { (widget: AnyAndroidFragment) in widget })
            else {
                task.finish()
                return
            }
            widget.removeFragment(fragment)
        case .androidXFragment(let fragment, _):
            guard let widget = mapAnyView(task.host.view, transform: { (widget: AnyAndroidXFragment) in widget })
            else {
                task.finish()
                return
            }
            widget.removeAndroidXFragment(fragment)
        }

        target.destroy()
        task.finish()
    }
    
    /** Returns a body of a given pritimive view, or `nil` if `view` is not a primitive view for
     this renderer.
     */
    func primitiveBody(for view: Any) -> AnyView? {
        // `as?` sees through `Optional`, but an optional view must render through its own
        // `body` so the wrapped view is mounted as a child element with its dynamic
        // properties injected; check the dynamic type to match `isPrimitiveView`
        guard type(of: view) is AndroidPrimitive.Type else { return nil }
        return (view as? AndroidPrimitive)?.renderedBody
    }

    /** Returns `true` if a given view type is a primitive view that should be deferred to this
     renderer.
     */
    func isPrimitiveView(_ type: Any.Type) -> Bool {
        type is AndroidPrimitive.Type
    }
}

private extension AndroidRenderer {

    /// Handler bound to the Android main looper, used to schedule reconciler updates.
    static let mainHandler = AndroidOS.Handler(try! JavaClass<AndroidOS.Looper>().getMainLooper())

    /// Creates a container view for hosting a fragment and adds it to the parent target.
    func mountFragmentContainer(
        to parent: AndroidTarget,
        context: AndroidContent.Context,
        activity: MainActivity
    ) -> AndroidWidget.FrameLayout? {
        let container = FrameLayout(context)
        container.setId(Self.viewClass.generateViewId())
        switch parent.storage {
        case .application:
            // inset the content from the system bars when drawing edge to edge
            container.setFitsSystemWindows(true)
            activity.setRootView(container)
        case .view(let parentView):
            guard parentView.is(ViewGroup.self), let viewGroup = parentView.as(ViewGroup.self) else {
                logError("\(self).\(#function) Parent View \(parentView.getClass().getName()) is not a ViewGroup)")
                return nil
            }
            viewGroup.addView(container)
        case .fragment, .androidXFragment:
            logError("\(self).\(#function) Nested fragments are not supported")
            return nil
        }
        return container
    }

    static let viewClass = try! JavaClass<AndroidView.View>()

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
