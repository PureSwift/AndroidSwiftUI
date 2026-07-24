#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
#endif

struct TextPlayground: View {
    @State private var counter = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Plain") { Text("Hello, world") }
                Example("Verbatim") { Text(verbatim: "Raw string, no interpolation") }
                Example("Interpolated") { Text("Counter is \(counter)") }
                Example("Bump the counter") { Button("Increment") { counter += 1 } }
                Example("Font sizes") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Large title").font(.largeTitle)
                        Text("Title").font(.title)
                        Text("Headline").font(.headline)
                        Text("Body").font(.body)
                        Text("Caption").font(.caption)
                    }
                }
                Example("Weight & style") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bold").bold()
                        Text("Semibold").fontWeight(.semibold)
                        Text("Italic").italic()
                        Text("System 24 heavy").font(.system(size: 24, weight: .heavy))
                    }
                }
                Example("Colors") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Red").foregroundColor(.red)
                        Text("Blue").foregroundColor(.blue)
                        Text("Green, bold, title").font(.title).bold().foregroundColor(.green)
                    }
                }
                Example("Line limit") {
                    Text("A longer passage of text that wraps onto multiple lines, capped at two by lineLimit so the rest is truncated.")
                        .lineLimit(2)
                }
                Example("Multiline") {
                    Text("A longer passage of text that wraps onto multiple lines when it no longer fits within the width of the screen.")
                }
                Example("Styled") {
                    Text("Blue on a rounded chip")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
    }
}

struct ButtonPlayground: View {
    @State private var taps = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Taps: \(taps)") { Text("Tap any button below") }
                Example("Title initializer") { Button("Tap me") { taps += 1 } }
                Example("Label closure") {
                    Button(action: { taps += 1 }) { Text("Custom label") }
                }
                Example("Styled label") {
                    Button(action: { taps += 1 }) {
                        Text("Padded label")
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                Example("Reset") { Button("Reset to zero") { taps = 0 } }
            }
        }
    }
}

struct TogglePlayground: View {
    @State private var a = false
    @State private var b = true
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Off by default") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Enable feature", isOn: $a)
                        Text(a ? "Feature is on" : "Feature is off")
                    }
                }
                Example("On by default") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Notifications", isOn: $b)
                        Text(b ? "Notifications on" : "Notifications off")
                    }
                }
            }
        }
    }
}

struct SliderPlayground: View {
    @State private var unit = 0.5
    @State private var wide = 25.0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("0...1") {
                    VStack(alignment: .leading, spacing: 8) {
                        Slider(value: $unit, in: 0...1)
                        Text("Value: \(Int(unit * 100))%")
                    }
                }
                Example("0...100") {
                    VStack(alignment: .leading, spacing: 8) {
                        Slider(value: $wide, in: 0...100)
                        Text("Value: \(Int(wide))")
                    }
                }
            }
        }
    }
}

struct TextFieldPlayground: View {
    @State private var name = ""
    @State private var city = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Name") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Your name", text: $name)
                        Text(name.isEmpty ? "Nothing typed yet" : "Hello, \(name)")
                    }
                }
                Example("City") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Your city", text: $city)
                        Text(city.isEmpty ? "—" : "You are in \(city)")
                    }
                }
            }
        }
    }
}

struct PickerPlayground: View {
    @State private var fruit = "Apple"
    @State private var size = 1
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("String selection") {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Fruit", selection: $fruit) {
                            Text("Apple").tag("Apple")
                            Text("Banana").tag("Banana")
                            Text("Cherry").tag("Cherry")
                        }
                        Text("Selected: \(fruit)")
                    }
                }
                Example("Int selection") {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Size", selection: $size) {
                            Text("Small").tag(0)
                            Text("Medium").tag(1)
                            Text("Large").tag(2)
                        }
                        Text("Size index: \(size)")
                    }
                }
            }
        }
    }
}

struct ProgressViewPlayground: View {
    @State private var progress = 0.25
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Indeterminate") { ProgressView() }
                Example("Determinate") {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: progress)
                        Text("\(Int(progress * 100))%")
                        Button("Advance") { progress = progress >= 1 ? 0 : progress + 0.25 }
                    }
                }
                Example("With a label") {
                    VStack(alignment: .leading, spacing: 12) {
                        ProgressView("Loading…")
                        ProgressView("Copying files", value: progress)
                    }
                }
                Example("progressViewStyle") {
                    VStack(alignment: .leading, spacing: 12) {
                        // determinate, but drawn as a ring
                        ProgressView(value: progress)
                            .progressViewStyle(.circular)
                        // indeterminate, but drawn as a bar
                        ProgressView()
                            .progressViewStyle(.linear)
                    }
                }
            }
        }
    }
}
