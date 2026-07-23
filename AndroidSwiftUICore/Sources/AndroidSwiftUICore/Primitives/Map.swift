//
//  Map.swift
//  AndroidSwiftUICore
//
//  A map showing a coordinate region with markers. The interpreter renders a
//  schematic map — markers positioned proportionally within the visible
//  region — until a tile provider is registered through the composable
//  registry (real tiles need a maps SDK and API key on Android).
//

public struct CLLocationCoordinate2D: Equatable, Sendable {
    public var latitude: Double
    public var longitude: Double
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct MKCoordinateSpan: Equatable, Sendable {
    public var latitudeDelta: Double
    public var longitudeDelta: Double
    public init(latitudeDelta: Double, longitudeDelta: Double) {
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
}

public struct MKCoordinateRegion: Equatable, Sendable {
    public var center: CLLocationCoordinate2D
    public var span: MKCoordinateSpan
    public init(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        self.center = center
        self.span = span
    }
}

/// A map annotation: a titled pin at a coordinate.
public struct MapMarker: Sendable {
    public var title: String
    public var coordinate: CLLocationCoordinate2D
    public var tint: Color?
    public init(_ title: String, coordinate: CLLocationCoordinate2D, tint: Color? = nil) {
        self.title = title
        self.coordinate = coordinate
        self.tint = tint
    }
}

public struct Map: View {

    internal let region: Binding<MKCoordinateRegion>
    internal let markers: [MapMarker]

    public init(coordinateRegion: Binding<MKCoordinateRegion>, markers: [MapMarker] = []) {
        self.region = coordinateRegion
        self.markers = markers
    }

    public typealias Body = Never
}

extension Map: PrimitiveView {
    public func _render(in context: ResolveContext) -> RenderNode {
        let value = region.wrappedValue
        let children = markers.enumerated().map { index, marker -> RenderNode in
            var props: [String: PropValue] = [
                "title": .string(marker.title),
                "latitude": .double(marker.coordinate.latitude),
                "longitude": .double(marker.coordinate.longitude),
            ]
            if let tint = marker.tint { props["tint"] = tint.propValue }
            return RenderNode(type: "MapMarker", id: context.path + "/marker#\(index)", props: props)
        }
        return RenderNode(
            type: "Map",
            id: context.path,
            props: [
                "centerLatitude": .double(value.center.latitude),
                "centerLongitude": .double(value.center.longitude),
                "spanLatitude": .double(value.span.latitudeDelta),
                "spanLongitude": .double(value.span.longitudeDelta),
            ],
            children: children
        )
    }
}
