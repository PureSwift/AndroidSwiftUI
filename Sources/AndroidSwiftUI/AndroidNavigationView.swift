//
//  AndroidNavigationView.swift
//  AndroidSwiftUI
//
//  Created by Alsey Coleman Miller on 7/16/26.
//

import AndroidKit

extension NavigationView: AndroidPrimitive {

    var renderedBody: AnyView {
        let proxy = _NavigationViewProxy(self)
        return AnyView(AndroidNavigationContainer(
            context: proxy.context,
            content: AnyView(proxy.content),
            pushedViews: proxy.pushedViews
        ))
    }
}

/// Native container for `NavigationView` and `NavigationStack`. Hosts the root content as an
/// always mounted child — so its state survives pushes and its `navigationDestination`
/// registrations stay live — stacks the pushed screen above it, and intercepts the system back
/// button to pop.
struct AndroidNavigationContainer {

    /// The navigation state shared with the `NavigationLink`s of the hosted screen.
    let context: NavigationContext

    /// The root content, always mounted.
    let content: AnyView

    /// The pushed screens stacked above the root, in order from bottom to top.
    let pushedViews: [AnyView]
}

extension AndroidNavigationContainer: ParentView {

    var children: [AnyView] {
        var views = [titled(content)]
        views += pushedViews.map {
            AnyView(AndroidSheetOverlay(content: titled($0), transition: .slide))
        }
        return views
    }
}

private extension AndroidNavigationContainer {

    /// Places a screen below a bar carrying its `navigationTitle`, if it declares one.
    ///
    /// The title is a preference, so it is only known once the screen's body has been
    /// evaluated — reading it off the static view tree would miss every title declared
    /// inside a composite view's body. `_delay` defers the bar until the reconciler has
    /// collected the screen's preferences, then re-renders with the resolved value.
    ///
    /// Screens without a title are hosted unchanged rather than wrapped in an empty bar,
    /// so a navigation stack that never sets one lays out exactly as it did before.
    func titled(_ screen: AnyView) -> AnyView {
        AnyView(NavigationTitleKey._delay { value in
            value._force { title in
                TitledScreen(title: title, screen: screen)
            }
        })
    }
}

/// A screen shown below its navigation title, if it has one.
///
/// Popping is left to the system back button, which the container already handles, rather
/// than a back control in the bar.
private struct TitledScreen: View {

    let title: AnyView?

    let screen: AnyView

    var body: some View {
        Group {
            if let title {
                VStack(spacing: 0) {
                    title
                    Divider()
                    screen
                }
            } else {
                screen
            }
        }
    }
}

extension AndroidNavigationContainer: AndroidViewRepresentable {

    typealias Coordinator = Void

    func makeAndroidView(context: Self.Context) -> BackHandlerView {
        let navigationContext = self.context
        let view = BackHandlerView(context.androidContext) {
            navigationContext.pop()
        }
        updateView(view)
        return view
    }

    func updateAndroidView(_ view: BackHandlerView, context: Self.Context) {
        updateView(view)
    }
}

private extension AndroidNavigationContainer {

    func updateView(_ view: BackHandlerView) {
        view.setBackHandlerEnabled(context.hasPushedDestinations)
    }
}
