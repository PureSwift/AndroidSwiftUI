# AndroidSwiftUI
SwiftUI for Android

<img width="200" height="398" alt="2026-07-24 13 23 04" src="https://github.com/user-attachments/assets/c72de93c-652d-49fd-b2e7-37cd584e1807" />

Write your UI in real SwiftUI, compiled natively with the official Swift SDK for
Android, and rendered by Jetpack Compose.

## How it works

There is no reconciler and no transpiler. Swift **evaluates** your view tree into
a small serializable node tree (`RenderNode`: a type, a stable identity, props, a
modifier list, children). A fixed, O(1) JNI bridge hands that tree to a Kotlin
interpreter, and Jetpack Compose does identity, layout, animation, input, and
lifecycle. State writes on the Swift side re-evaluate the affected subtree and
push a new tree; Compose diffs and redraws.

```
  your SwiftUI code
        │  evaluate (native Swift)
        ▼
  RenderNode tree  ──(fixed O(1) JNI, typed nodes)──►  Kotlin Render(node)
        ▲                                                     │
        └────────── callbacks (tap/edit/…) ◄─────────────────┘  Jetpack Compose
```

The conversion surface is the closed primitive vocabulary (~40 node types, ~30
modifiers) — *not* all of Swift — so generic view wrappers, custom modifiers,
`@ViewBuilder` helpers, property wrappers, macros, and any pure-Swift package all
just work. The same interpreter is Compose Multiplatform, so the whole pipeline
also runs on the desktop JVM — the project builds and tests on a Mac without an
emulator.

## Layout

**Swift**

| Module | Role |
| --- | --- |
| `SwiftUICore` | The platform-neutral evaluation core: `View`/`ViewBuilder`, `@State`/`@Binding`/`@Environment`/`@Observable`, the primitives and modifiers, the evaluator, and the `RenderNode` IR. No Android or JVM imports — builds and tests on any host. |
| `ComposeUI` | The JNI bridge: materializes the IR into Kotlin `ViewNode` objects and dispatches callbacks back. Platform-neutral (desktop JVM + Android). |
| `AndroidSwiftUI` | The umbrella app code imports. `@_exported import`s `SwiftUICore` and `ComposeUI`, and adds the Android host (android.view bridging: `MainActivity`, `Application`, the host view). |

**Kotlin** (reusable libraries at the repo root; the demo apps consume them)

| Module | Role |
| --- | --- |
| `:composeui` | The Compose Multiplatform interpreter: `Render()`, `ViewNode`, `TreeStore`, the callback sink, the Android host view. Renders on Android and the desktop JVM. |
| `:androidbridge` | A reusable Kotlin-only Android library: the JNI host glue (`SwiftObject`, `NativeLibrary`, `Runnable`) between a Swift-built `.so` and the JVM. No Swift, no Compose. |
| `:demo-app` | The Android demo — a catalog of one playground screen per supported feature. Depends on `:composeui` + `:androidbridge`. |
| `:demo-desktop` | The macOS desktop rig: runs the interpreter on the host JVM, driven by the Swift core through a `.dylib`. Depends on `:composeui`. |

The demo's SwiftUI sources live in `Demo/App.swiftpm/Sources` and are shared: the
Android app and the desktop rig both render them (Android-only screens — Map,
Video, native-view interop — are gated out on desktop).

## Building the Android demo

Requires the [Swift SDK for Android](https://www.swift.org/documentation/articles/swift-on-android.html)
and Android Studio's JDK (a newer system JDK is too new for AGP).

```bash
# 1. cross-compile the Swift core for Android
cd Demo/swift
JAVA_HOME="…/Android Studio.app/Contents/jbr/Contents/Home" \
  swift build --swift-sdk aarch64-unknown-linux-android28

# 2. stage the .so, then assemble & install (gradle root is the repo root)
cp .build/aarch64-unknown-linux-android28/debug/libSwiftAndroidApp.so \
   ../app/src/main/jniLibs/arm64-v8a/
cd ../..
JAVA_HOME="…/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew :demo-app:assembleDebug
```

## Running the desktop rig (macOS)

The whole pipeline — Swift `.dylib` → JNI → Kotlin interpreter → a Compose
window — runs on the host JVM, no emulator needed:

```bash
swift build --product SwiftUIDesktopDemo
JAVA_HOME="…/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew :demo-desktop:run
```

## Tests

`SwiftUICore` is fully host-testable — evaluator, identity/state semantics, and
node emission, no JVM or emulator:

```bash
cd SwiftUICore && swift test
```
