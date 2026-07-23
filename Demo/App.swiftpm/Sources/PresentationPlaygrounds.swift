#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct NavigationPlayground: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Value-based navigation").padding()
                NavigationLink("Push value 1", value: 1)
                NavigationLink("Push value 2", value: 2)
                Divider()
                Text("Classic navigation").padding()
                NavigationLink("Push a destination view", destination: NavDetail(label: "Pushed directly"))
            }
        }
        .navigationDestination(for: Int.self) { value in
            NavDetail(label: "Value \(value)", next: value + 1)
        }
    }
}

struct NavDetail: View {
    let label: String
    var next: Int? = nil
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Text(label)
            if let next, next <= 4 {
                NavigationLink("Push value \(next)", value: next)
            }
            Button("Pop with dismiss") { dismiss() }
        }
        .padding()
        .navigationTitle(label)
    }
}

struct TabViewPlayground: View {
    @State private var selection = 0
    var body: some View {
        TabView(selection: $selection) {
            VStack(spacing: 16) {
                Text("First tab content")
                Button("Jump to third tab") { selection = 2 }
            }
            .tabItem { Text("One") }.tag(0)
            Text("Second tab content").tabItem { Text("Two") }.tag(1)
            Text("Third tab content").tabItem { Text("Three") }.tag(2)
        }
    }
}

struct SheetPlayground: View {
    @State private var full = false
    @State private var medium = false
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button("Present full-size sheet") { full = true }
                Button("Present medium detent sheet") { medium = true }
            }
            .padding()
        }
        .sheet(isPresented: $full) {
            SheetBody(title: "Full-size sheet")
        }
        .sheet(isPresented: $medium) {
            SheetBody(title: "Medium sheet").presentationDetents([.medium])
        }
    }
}

struct SheetBody: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
            Button("Dismiss") { dismiss() }
        }
        .padding()
    }
}

struct AlertPlayground: View {
    @State private var simple = false
    @State private var confirm = false
    @State private var result = "No choice yet"
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button("Show simple alert") { simple = true }
                Button("Show confirmation") { confirm = true }
                Text(result)
            }
            .padding()
        }
        .alert("A simple alert", isPresented: $simple, message: "This is the message body.")
        .alert("Delete item?", isPresented: $confirm, message: "This cannot be undone.", buttons: [
            AlertButton("Cancel", role: .cancel) { result = "Cancelled" },
            AlertButton("Delete", role: .destructive) { result = "Deleted" },
        ])
    }
}
