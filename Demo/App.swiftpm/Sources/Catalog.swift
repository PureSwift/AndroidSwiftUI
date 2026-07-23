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
        CatalogEntry(id: "button", title: "Button", screen: AnyCatalogScreen(ButtonPlayground())),
        CatalogEntry(id: "toggle", title: "Toggle", screen: AnyCatalogScreen(TogglePlayground())),
        CatalogEntry(id: "slider", title: "Slider", screen: AnyCatalogScreen(SliderPlayground())),
        CatalogEntry(id: "textfield", title: "TextField", screen: AnyCatalogScreen(TextFieldPlayground())),
        CatalogEntry(id: "picker", title: "Picker", screen: AnyCatalogScreen(PickerPlayground())),
        CatalogEntry(id: "progress", title: "ProgressView", screen: AnyCatalogScreen(ProgressViewPlayground())),
        CatalogEntry(id: "stack", title: "Stacks", screen: AnyCatalogScreen(StackPlayground())),
        CatalogEntry(id: "spacer", title: "Spacer & Divider", screen: AnyCatalogScreen(SpacerDividerPlayground())),
        CatalogEntry(id: "color", title: "Color", screen: AnyCatalogScreen(ColorPlayground())),
        CatalogEntry(id: "scroll", title: "ScrollView", screen: AnyCatalogScreen(ScrollViewPlayground())),
        CatalogEntry(id: "list", title: "List", screen: AnyCatalogScreen(ListPlayground())),
        CatalogEntry(id: "grid", title: "Grid", screen: AnyCatalogScreen(GridPlayground())),
        CatalogEntry(id: "modifier", title: "Modifiers", screen: AnyCatalogScreen(ModifierPlayground())),
        CatalogEntry(id: "interaction", title: "Interaction", screen: AnyCatalogScreen(InteractionPlayground())),
        CatalogEntry(id: "navigation", title: "Navigation", screen: AnyCatalogScreen(NavigationPlayground())),
        CatalogEntry(id: "tab", title: "TabView", screen: AnyCatalogScreen(TabViewPlayground())),
        CatalogEntry(id: "sheet", title: "Sheet", screen: AnyCatalogScreen(SheetPlayground())),
        CatalogEntry(id: "alert", title: "Alert", screen: AnyCatalogScreen(AlertPlayground())),
        CatalogEntry(id: "state", title: "State", screen: AnyCatalogScreen(StatePlayground())),
        CatalogEntry(id: "environment", title: "Environment", screen: AnyCatalogScreen(EnvironmentPlayground())),
        CatalogEntry(id: "observable", title: "Observable", screen: AnyCatalogScreen(ObservablePlayground())),
        CatalogEntry(id: "bindable", title: "Bindable", screen: AnyCatalogScreen(BindablePlayground())),
    ]
}
