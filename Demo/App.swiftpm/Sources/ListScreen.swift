#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

/// List rows with pull to refresh.
struct ListScreen: View {

    @State
    private var items = (1...10).map(ListItem.init)

    var body: some View {
        #if canImport(AndroidSwiftUI)
        AndroidListView(items) { item in
            Text(item.title)
        }
        .refreshable {
            await addItem()
        }
        #else
        List(items) { item in
            Text(item.title)
        }
        .refreshable {
            await addItem()
        }
        #endif
    }

    private func addItem() async {
        // simulate a network refresh
        try? await Task.sleep(for: .seconds(1))
        items.append(ListItem(id: items.count + 1))
    }
}

struct ListItem: Identifiable {

    let id: Int

    var title: String {
        "Row \(id)"
    }
}
