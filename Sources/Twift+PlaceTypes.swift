import Foundation

public struct Place: Codable, Identifiable {
  public typealias ID = String
  public let id: ID
  public let fullName: String
  public let containedWithin: [Place.ID]?
  public let country: String?
  public let countryCode: String?
  public let geo: GeoJSON?
  public let name: String?
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
  enum Fields: String, Codable, CaseIterable {
    case geo
    case name
    case placeType = "place_type"
    case country
    case countryCode = "country_code"
    case containedWithin = "contained_within"
  }
}
