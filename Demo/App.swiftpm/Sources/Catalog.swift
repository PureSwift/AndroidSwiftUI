#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// A component catalog: one playground per supported SwiftUI feature, navigated
/// with a `NavigationStack` and a lazy `List`.
struct ContentView: View {

    var body: some View {
        NavigationStack {
            List(CatalogEntry.all) { entry in
                NavigationLink(entry.title, destination: entry.screen)
            }
            .navigationTitle("Catalog")
        }
    }
}

struct CatalogEntry: Identifiable {
    let id: String
    let title: String
    let screen: AnyCatalogScreen

    static let all: [CatalogEntry] = [
        CatalogEntry(id: "text", title: "Text", screen: AnyCatalogScreen(TextPlayground())),
        CatalogEntry(id: "style", title: "Styling", screen: AnyCatalogScreen(StylePlayground())),
        CatalogEntry(id: "button", title: "Button", screen: AnyCatalogScreen(ButtonPlayground())),
        CatalogEntry(id: "toggle", title: "Toggle", screen: AnyCatalogScreen(TogglePlayground())),
        CatalogEntry(id: "slider", title: "Slider", screen: AnyCatalogScreen(SliderPlayground())),
        CatalogEntry(id: "textfield", title: "TextField", screen: AnyCatalogScreen(TextFieldPlayground())),
        CatalogEntry(id: "focus", title: "FocusState", screen: AnyCatalogScreen(FocusPlayground())),
        CatalogEntry(id: "picker", title: "Picker", screen: AnyCatalogScreen(PickerPlayground())),
        CatalogEntry(id: "progress", title: "ProgressView", screen: AnyCatalogScreen(ProgressViewPlayground())),
        CatalogEntry(id: "morecontrols", title: "More Controls", screen: AnyCatalogScreen(MoreControlsPlayground())),
        CatalogEntry(id: "stack", title: "Stacks", screen: AnyCatalogScreen(StackPlayground())),
        CatalogEntry(id: "frame", title: "Frames", screen: AnyCatalogScreen(FramePlayground())),
        CatalogEntry(id: "spacer", title: "Spacer & Divider", screen: AnyCatalogScreen(SpacerDividerPlayground())),
        CatalogEntry(id: "color", title: "Color", screen: AnyCatalogScreen(ColorPlayground())),
        CatalogEntry(id: "graphics", title: "Graphics", screen: AnyCatalogScreen(GraphicsPlayground())),
        CatalogEntry(id: "map", title: "Map", screen: AnyCatalogScreen(MapPlayground())),
        CatalogEntry(id: "video", title: "Video", screen: AnyCatalogScreen(VideoPlayground())),
        CatalogEntry(id: "scroll", title: "ScrollView", screen: AnyCatalogScreen(ScrollViewPlayground())),
        CatalogEntry(id: "list", title: "List", screen: AnyCatalogScreen(ListPlayground())),
        CatalogEntry(id: "grid", title: "Grid", screen: AnyCatalogScreen(GridPlayground())),
        CatalogEntry(id: "form", title: "Form", screen: AnyCatalogScreen(FormPlayground())),
        CatalogEntry(id: "modifier", title: "Modifiers", screen: AnyCatalogScreen(ModifierPlayground())),
        CatalogEntry(id: "representable", title: "Custom Views", screen: AnyCatalogScreen(RepresentablePlayground())),
        CatalogEntry(id: "appearance", title: "Appearance", screen: AnyCatalogScreen(AppearancePlayground())),
        CatalogEntry(id: "animation", title: "Animation", screen: AnyCatalogScreen(AnimationPlayground())),
        CatalogEntry(id: "interaction", title: "Interaction", screen: AnyCatalogScreen(InteractionPlayground())),
        CatalogEntry(id: "gesture", title: "Gestures", screen: AnyCatalogScreen(GesturePlayground())),
        CatalogEntry(id: "navigation", title: "Navigation", screen: AnyCatalogScreen(NavigationPlayground())),
        CatalogEntry(id: "searchable", title: "Searchable", screen: AnyCatalogScreen(SearchablePlayground())),
        CatalogEntry(id: "toolbar", title: "Toolbar", screen: AnyCatalogScreen(ToolbarPlayground())),
        CatalogEntry(id: "tab", title: "TabView", screen: AnyCatalogScreen(TabViewPlayground())),
        CatalogEntry(id: "sheet", title: "Sheet", screen: AnyCatalogScreen(SheetPlayground())),
        CatalogEntry(id: "alert", title: "Alert", screen: AnyCatalogScreen(AlertPlayground())),
        CatalogEntry(id: "state", title: "State", screen: AnyCatalogScreen(StatePlayground())),
        CatalogEntry(id: "environment", title: "Environment", screen: AnyCatalogScreen(EnvironmentPlayground())),
        CatalogEntry(id: "observable", title: "Observable", screen: AnyCatalogScreen(ObservablePlayground())),
        CatalogEntry(id: "bindable", title: "Bindable", screen: AnyCatalogScreen(BindablePlayground())),
    ]
}
