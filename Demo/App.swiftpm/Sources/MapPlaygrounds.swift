#if canImport(AndroidSwiftUI)
import AndroidSwiftUI
#else
import SwiftUI
import MapKit
#endif

struct MapPlayground: View {
    @State private var lima = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.046, longitude: -77.043),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )
    @State private var cupertino = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Example("Region with markers") {
                    Map(coordinateRegion: $lima, markers: [
                        MapMarker("Plaza Mayor", coordinate: CLLocationCoordinate2D(latitude: -12.046, longitude: -77.030)),
                        MapMarker("Miraflores", coordinate: CLLocationCoordinate2D(latitude: -12.120, longitude: -77.030), tint: .blue),
                        MapMarker("Callao", coordinate: CLLocationCoordinate2D(latitude: -12.055, longitude: -77.100), tint: .green),
                    ])
                }
                Example("Plain region") {
                    Map(coordinateRegion: $cupertino)
                        .frame(height: 140)
                        .cornerRadius(12)
                }
            }
        }
    }
}
