#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct SearchablePlayground: View {
    @State private var query = ""

    private let fruits = [
        "Apple", "Apricot", "Banana", "Blueberry", "Cherry", "Grape",
        "Lemon", "Lime", "Mango", "Orange", "Peach", "Pear", "Plum",
    ]

    private var filtered: [String] {
        query.isEmpty ? fruits : fruits.filter { $0.lowercased().contains(query.lowercased()) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if filtered.isEmpty {
                    Text("No matches").foregroundColor(.gray)
                }
                ForEach(filtered, id: \.self) { fruit in
                    Text(fruit)
                }
            }
            .padding()
        }
        .searchable(text: $query, prompt: "Search fruit")
        .navigationTitle("Searchable")
    }
}
