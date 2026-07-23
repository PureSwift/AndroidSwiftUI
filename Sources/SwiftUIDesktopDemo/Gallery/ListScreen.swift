import AndroidSwiftUICore

/// A lazy list with pull to refresh. Rows are evaluated on demand, so the
/// large-list variant scrolls without materializing every row up front.
struct ListScreen: View {

    @State
    private var items = (1...30).map(ListItem.init)

    var body: some View {
        List(items) { item in
            Text(item.title)
        }
        .refreshable {
            await addItem()
        }
    }

    private func addItem() async {
        try? await Task.sleep(for: .seconds(1))
        items.insert(ListItem(id: items.count + 1), at: 0)
    }
}

struct ListItem: Identifiable {

    let id: Int

    var title: String {
        "Row \(id)"
    }
}
