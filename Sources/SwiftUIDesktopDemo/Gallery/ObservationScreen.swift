import AndroidSwiftUICore

import Observation

/// Observable objects shared through the environment.
@Observable
final class GalleryModel {

    var counter = 0
}

struct ObservationScreen: View {

    @State
    private var model = GalleryModel()

    var body: some View {
        ObservationCounterView()
            .environment(model)
    }
}

struct ObservationCounterView: View {

    @Environment(GalleryModel.self)
    private var model

    var body: some View {
        VStack(spacing: 16) {
            Text("Observable environment object")
            Text(verbatim: "Counter: \(model.counter)")
            Button("Increment") {
                model.counter += 1
            }
        }
    }
}
