#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

import Foundation

struct ContentView: View {
    
    @State
    var counter = 1
    
    @State
    var date = Date()
    
    @State
    var task: Task<Void, Never>?
    
    var items: [Item] {
        (0 ..< counter).map { Item(id: $0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(spacing: 20) {
                        Image("globe")
                        Text("Hello World")
                        Text(verbatim: date.formatted(date: .numeric, time: .complete))
                        if counter > 0 {
                            HStack {
                                Text("Counter:")
                                Text(verbatim: counter.description)
                            }
                        }
                        Button("Increment") {
                            counter += 1
                            if counter > 20 {
                                counter = 0
                            }
                        }
                    }
                    .onAppear {
                        task = Task {
                            while true {
                                do {
                                    try await Task.sleep(for: .seconds(1))
                                    date = Date()
                                }
                                catch {
                                    return
                                }
                            }
                        }
                    }
                    .onDisappear {
                        task?.cancel()
                        task = nil
                    }
                }
                NavigationLink("Show Items", destination: ItemsView(items: items))
            }
        }
    }
}

struct ItemsView: View {

    let items: [Item]

    var body: some View {
        List(items) { item in
            NavigationLink(item.title, destination: DetailView(item: item))
        }
    }
}

struct DetailView: View {

    let item: Item

    var body: some View {
        Text(verbatim: "Detail for \(item.title)")
    }
}

struct Item: Identifiable {
    let id: Int
    var title: String {
        "Item \(id + 1)"
    }
}
    
