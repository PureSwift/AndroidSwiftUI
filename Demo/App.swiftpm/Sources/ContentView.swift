#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
typealias List = AndroidListView
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
        HStack {
            HStack {
                VStack(spacing: 20) {
                    Image("globe")
                    Text("Hello World")
                    Text(verbatim: date.formatted(date: .numeric, time: .complete))
                    HStack {
                        Text("Counter:")
                        Text(verbatim: counter.description)
                    }
                    Button("Increment") {
                        counter += 1
                        if counter > 20 {
                            counter = 1
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
        }
        List(items) { item in
            Text(verbatim: item.title)
        }
    }
}

struct Item: Identifiable {
    let id: Int
    var title: String {
        "Item \(id + 1)"
    }
}
    
