import Foundation

/// The place tagged in a Tweet is not a primary object on any endpoint, but can be found and expanded in the Tweet resource.
public struct Place: Codable, Identifiable {
  public typealias ID = String
  
  /// The unique identifier of the expanded place, if this is a point of interest tagged in the Tweet.
  public let id: ID
  
  /// A longer-form detailed place name.
  public let fullName: String
  
  /// Returns the identifiers of known places that contain the referenced place.
  public let containedWithin: [Place.ID]?
  
  /// The full-length name of the country this place belongs to.
  public let country: String?
  
  /// The ISO Alpha-2 country code this place belongs to.
  public let countryCode: String?
  
  /// Contains place details in GeoJSON format.
  public let geo: GeoJSON?
  
  /// The short name of this place.
  public let name: String?
  
  /// Specified the particular type of information represented by this place information, such as a city name, or a point of interest.
  public let placeType: String?
}

public struct GeoJSON: Codable {
  public let type: String?
  public let bbox: [Double]
}

/// An object containing details for a location
public struct Geo: Codable {
  /// The location's coordinates
  public let coordinates: Coordinates?
  
  /// The location's unique ID
  public let placeId: String
  
  /// The GeoJSON type for this object
  public let type: GeoJSONType?
  
  public struct Coordinates: Codable {
    /// The location's latitude and longitude
    public let coordinates: [Double]
  }
}

public enum GeoJSONType: String, Codable {
  /// A Feature object represents a spatially bounded thing.
  case Feature
  
  /// A GeoJSON object with the type "FeatureCollection" is a FeatureCollection object.
  ///
  /// A FeatureCollection object has a member with the name "features".  The value of "features" is a JSON array. Each element of the array is a Feature object as defined above.  It is possible for this array to be empty.
  case FeatureCollection
  
  /// For type "Point", the "coordinates" member is a single position.
  case Point
  
  /// For type "MultiPoint", the "coordinates" member is an array of positions.
  case MultiPoint
  
  /// For type "LineString", the "coordinates" member is an array of two or more positions.
  case LineString
  
  /// For type "MultiLineString", the "coordinates" member is an array of LineString coordinate arrays.
  case MultiLineString
  
  /// To specify a constraint specific to Polygons, it is useful to introduce the concept of a linear ring:
  /// - A linear ring is a closed LineString with four or more positions.
  /// - The first and last positions are equivalent, and they MUST contain identical values; their representation SHOULD also be identical.
  /// - A linear ring is the boundary of a surface or the boundary of a hole in a surface.
  /// - A linear ring MUST follow the right-hand rule with respect to the area it bounds, i.e., exterior rings are counterclockwise, and holes are clockwise.
  /// Note: the [GJ2008] specification did not discuss linear ring winding order.  For backwards compatibility, parsers SHOULD NOT reject Polygons that do not follow the right-hand rule.
  ///
  /// Though a linear ring is not explicitly represented as a GeoJSON geometry type, it leads to a canonical formulation of the Polygon geometry type definition as follows:
  /// - For type "Polygon", the "coordinates" member MUST be an array of linear ring coordinate arrays.
  /// - For Polygons with more than one of these rings, the first MUST be the exterior ring, and any others MUST be interior rings.  The exterior ring bounds the surface, and the interior rings (if present) bound holes within the surface.
  case Polygon
  
  /// For type "MultiPolygon", the "coordinates" member is an array of Polygon coordinate arrays.
  case MultiPolygon
  
  /// A GeoJSON object with type "GeometryCollection" is a Geometry object.
  ///
  /// A GeometryCollection has a member with the name "geometries".  The value of "geometries" is an array.  Each element of this array is a GeoJSON Geometry object.  It is possible for this array to be empty.
  case GeometryCollection
}

extension Place: Fielded {
  public typealias Field = PartialKeyPath<Self>
  
  static internal func fieldName(field: PartialKeyPath<Place>) -> String? {
    switch field {
    case \.geo: return "geo"
    case \.name: return "name"
    case \.placeType: return "place_type"
    case \.country: return "country"
    case \.countryCode: return "country_code"
    case \.containedWithin: return "contained_within"
    default: return nil
    }
  }
  
  static internal var fieldParameterName = "place.fields"
}
