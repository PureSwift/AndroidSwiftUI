# Representable Architecture

AndroidSwiftUI provides a family of protocols equivalent to SwiftUI's `UIViewRepresentable`
and `UIViewControllerRepresentable` for integrating Android platform components into the
SwiftUI view hierarchy.

| AndroidSwiftUI | UIKit equivalent | Wraps |
|---|---|---|
| `AndroidViewRepresentable` | `UIViewRepresentable` | `android.view.View` |
| `AndroidFragmentRepresentable` | `UIViewControllerRepresentable` | `android.app.Fragment` |
| `AndroidXFragmentRepresentable` | `UIViewControllerRepresentable` | `androidx.fragment.app.Fragment` |
| `AndroidActivityRepresentable` | *(presentation)* | `android.app.Activity` via `Intent` |
| `AndroidComposeRepresentable` | — | Jetpack Compose content |

## Common infrastructure

All four protocols refine `AndroidRepresentable`, which contributes the `Coordinator`
associated type and `makeCoordinator()`. A coordinator is created once when the component
is mounted, retained by the renderer for the lifetime of the underlying Java object
(keyed by Java object identity in `RepresentableCoordinatorStorage`), and passed back on
every update through `AndroidRepresentableContext`:

```swift
public struct AndroidRepresentableContext<Representable: AndroidRepresentable> {
    public let coordinator: Representable.Coordinator
    public let androidContext: AndroidContent.Context
    public let environment: EnvironmentValues
    public let transaction: Transaction
}
```

The per-view `EnvironmentValues` and the current `Transaction` are captured by the renderer
from the mounted host immediately before each representable entry point
(`RepresentableHostContext`), so they reflect the environment of the enclosing hierarchy at
mount, update, and unmount time.

Each protocol is backed by a type-erased renderer protocol (`AnyAndroidView`,
`AnyAndroidFragment`) with `create` / `update` / `remove` entry points. The
`StackReconciler` calls these through `AndroidRenderer` when mounting, updating,
and unmounting targets.

## `AndroidViewRepresentable`

The direct analog of `UIViewRepresentable`:

```swift
struct MapView: AndroidViewRepresentable {

    let zoom: Float

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeAndroidView(context: Context) -> AndroidWidget.FrameLayout {
        // create the view once, wire listeners to context.coordinator
        FrameLayout(context.androidContext)
    }

    func updateAndroidView(_ view: AndroidWidget.FrameLayout, context: Context) {
        // push new SwiftUI state into the view
    }

    static func dismantleAndroidView(_ view: AndroidWidget.FrameLayout, coordinator: Coordinator) {
        // release listeners and resources
    }

    final class Coordinator { }
}
```

Lifecycle mapping:

- mount → `makeCoordinator()` + `makeAndroidView(context:)`, view added to the parent `ViewGroup`
- reconcile → `updateAndroidView(_:context:)`
- unmount → `dismantleAndroidView(_:coordinator:)`, view removed from its parent

### Sizing

The optional `sizeThatFits(_:view:context:)` requirement is the equivalent of
`UIViewRepresentable.sizeThatFits`. Returning a `CGSize` (in points) converts it to pixels
using the display density and applies it as the view's `LayoutParams` after every
create and update pass; returning `nil` (the default) defers to the parent's layout.

## `AndroidFragmentRepresentable`

The closest Android analog of `UIViewControllerRepresentable`. Fragments are the
Android unit of embeddable, lifecycle-aware UI, so `makeFragment(context:)` returns a
fragment which the renderer hosts in a dedicated container view:

1. The renderer creates a `FrameLayout` with a generated view id and adds it to the parent.
2. The fragment is attached with `FragmentManager.beginTransaction().add(containerId, fragment).commit()`.
3. On unmount the fragment is removed with a `remove` transaction and the container is
   detached from the hierarchy.

```swift
struct PlayerScreen: AndroidFragmentRepresentable {

    let videoURL: String

    func makeFragment(context: Context) -> Fragment {
        Fragment(callback: .init(onViewCreated: { view, savedInstanceState in
            // configure the fragment's view
        }))
    }

    func updateFragment(_ fragment: Fragment, context: Context) { }
}
```

Nested fragments (a fragment target inside another fragment) are not currently supported.

Fragment lifecycle events (`onStart`, `onResume`, `onPause`, `onStop`, `onDestroyView`,
`onViewCreated`) are forwarded from the Kotlin `Fragment` class to the Swift
`Fragment.Callback` closures, so conforming types can surface them to their coordinator.

### AndroidX fragments

`AndroidXFragmentRepresentable` is the same shape for `androidx.fragment.app.Fragment`,
hosted with the support `FragmentManager` (`FragmentActivity.getSupportFragmentManager()`).
This requires the main activity to extend `androidx.fragment.app.FragmentActivity`, which
the demo's `MainActivity` now does. Minimal AndroidX bindings (`AndroidXFragment`,
`AndroidXFragmentManager`, `AndroidXFragmentTransaction`, `AndroidXFragmentActivity`) are
declared locally until AndroidKit provides them.

## `AndroidActivityRepresentable`

Activities cannot be embedded in another view hierarchy — they are always presented
full screen by the system. Mounting an `AndroidActivityRepresentable` therefore *starts*
the activity described by `makeIntent(context:)`, comparable to `fullScreenCover`:

```swift
struct SettingsScreen: AndroidActivityRepresentable {

    func makeIntent(context: Context) -> AndroidContent.Intent {
        Intent("com.example.SETTINGS")
    }
}
```

A zero-sized placeholder view occupies the representable's position in the hierarchy.
Communication with the presented activity happens through intent extras and the coordinator.

### Activity results

When mounted inside an activity, the intent is started with
`ActivityCompat.startActivityForResult` using a request code allocated by
`ActivityResultRegistry`. The main activity forwards `onActivityResult` to Swift, which
dispatches an `ActivityResult` (result code + data intent) to the representable:

```swift
struct DocumentPicker: AndroidActivityRepresentable {

    func makeIntent(context: Context) -> AndroidContent.Intent {
        Intent("android.intent.action.OPEN_DOCUMENT")
    }

    func onActivityResult(_ result: ActivityResult, coordinator: Void) {
        guard result.isSuccess else { return }
        // read result.data
    }
}
```

## `AndroidComposeRepresentable`

Composable functions require the Kotlin compiler and cannot be authored in Swift.
The bridge is split across the language boundary:

- **Kotlin**: implement the `com.pureswift.swiftandroid.ComposeContent` interface
  (`@Composable fun Content()`). State can be sourced from Swift through adapter
  objects backed by `SwiftObject`, as `ComposeListView` does with `ListViewAdapter`.
- **Swift**: conform to `AndroidComposeRepresentable` and return the `ComposeContent`
  Java object from `makeComposeContent(context:)`.

The renderer hosts the content in a `ComposeHostView` (a `FrameLayout` wrapping a
`ComposeView`, since `ComposeView` is final). Every SwiftUI update calls
`updateComposeContent(_:context:)` and then `refresh()`, which bumps a
`mutableIntStateOf` version read inside the composition. Because the version is a
recomposition dependency rather than an identity `key`, updates recompose the content
in place and internal Compose state — scroll positions, animations, `remember`ed
values keyed on stable inputs — survives across SwiftUI updates. Content is wrapped
in the app's Material theme at the interop boundary.

## Future work

- Nested fragments (a fragment representable inside another fragment target).
- `registerForActivityResult`-style typed contracts on top of `ActivityResult`.
- Full layout negotiation once the renderer adopts the Fiber reconciler
  (`sizeThatFits` currently receives an `unspecified` proposal).
