import AndroidSwiftUICore

/// Stack containers and cross-axis alignment.
struct StacksScreen: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AlignmentSection(title: "VStack .leading", alignment: .leading)
                AlignmentSection(title: "VStack .center", alignment: .center)
                AlignmentSection(title: "VStack .trailing", alignment: .trailing)
                Divider()
                Text("HStack with Spacer")
                HStack {
                    Text("Start")
                    Spacer()
                    Text("End")
                }
                Divider()
                Text("LazyVStack")
                LazyVStack(alignment: .leading) {
                    Text("Lazy one")
                    Text("Lazy two, longer")
                }
                Divider()
                ZStackSection(title: "ZStack .center", alignment: .center)
                ZStackSection(title: "ZStack .topLeading", alignment: .topLeading)
                ZStackSection(title: "ZStack .bottomTrailing", alignment: .bottomTrailing)
            }
        }
    }
}

struct ZStackSection: View {

    let title: String

    let alignment: Alignment

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
            ZStack(alignment: alignment) {
                Color.blue
                    .frame(width: 240, height: 120)
                Text("On top")
            }
            Divider()
        }
    }
}

struct AlignmentSection: View {

    let title: String

    let alignment: HorizontalAlignment

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
            VStack(alignment: alignment) {
                Text("Row one")
                Text("Row two, longer")
            }
            Divider()
        }
    }
}
