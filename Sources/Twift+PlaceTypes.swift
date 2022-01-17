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
  public let coordinates: Coordinates
  
  /// The location's unique ID
  public let placeId: String
  
  public let type: String?
  
  public struct Coordinates: Codable {
    /// The location's latitude and longitude
    public let coordinates: [Double]
  }
}

public extension Place {
  enum Fields: String, Codable, CaseIterable, Field {
    case geo
    case name
    case placeType = "place_type"
    case country
    case countryCode = "country_code"
    case containedWithin = "contained_within"
    
    static let parameterName = "place.fields"
  }
}
