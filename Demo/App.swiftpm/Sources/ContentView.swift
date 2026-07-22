#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

import Foundation

/// Gallery of playground screens, one per supported SwiftUI feature.
struct ContentView: View {

    var body: some View {
        NavigationStack {
            List(GalleryScreen.allCases) { screen in
                NavigationLink(screen.title, destination: screen.destination)
            }
        }
    }
}

/// The catalog of playground screens.
///
/// Each case demonstrates one feature area. This enum doubles as the coverage
/// checklist for what the framework currently supports.
enum GalleryScreen: String, CaseIterable, Identifiable {

    case text
    case buttons
    case stacks
    case list
    case navigation
    case sheets
    case tabs
    case observation
    case state
    case modifiers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text: return "Text"
        case .buttons: return "Buttons"
        case .stacks: return "Stacks & Alignment"
        case .list: return "List & Refresh"
        case .navigation: return "Navigation"
        case .sheets: return "Sheets"
        case .tabs: return "Tabs"
        case .observation: return "Observation"
        case .state: return "State"
        case .modifiers: return "Modifiers"
        }
    }

    var destination: AnyView {
        switch self {
        case .text: return AnyView(TextScreen())
        case .buttons: return AnyView(ButtonScreen())
        case .stacks: return AnyView(StacksScreen())
        case .list: return AnyView(ListScreen())
        case .navigation: return AnyView(NavigationScreen())
        case .sheets: return AnyView(SheetScreen())
        case .tabs: return AnyView(TabScreen())
        case .observation: return AnyView(ObservationScreen())
        case .state: return AnyView(StateScreen())
        case .modifiers: return AnyView(ModifierScreen())
        }
    }
}
