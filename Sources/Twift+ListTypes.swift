import Foundation

/// The list object contains Twitter Lists metadata describing the referenced List. The List object is the primary object returned in the List lookup endpoint.
public struct List: Codable, Identifiable {
  public typealias ID = String
  
  /// The unique identifier of this List.
  public let id: ID
  
  /// The name of the List, as defined when creating the List.
  public let name: String
  
  /// The UTC datetime that the List was created on Twitter.
  public let createdAt: Date?
  
  /// A brief description to let users know about the List.
  public let description: String?
  
  /// Shows how many users follow this List
  public let followerCount: Int?
  
  /// Shows how many members are part of this List.
  public let memberCount: Int?
  
  /// Indicates if the List is private.
  public let `private`: Bool?
  
  /// Unique identifier of this List's owner.
  public let ownerId: User.ID?
}

extension List: Fielded {
  /// Additional fields that can be requested for List objects
  public enum Fields: String, CaseIterable, Field {
    case createdAt = "created_at"
    case description
    case followerCount = "follower_count"
    case memberCount = "member_count"
    case `private`
    case ownerId = "owner_id"
    
    static let parameterName = "list.fields"
  }
}

extension List: Expandable {
  public enum Expansions: Expansion {
    case ownerId(fields: Set<User.Fields>)
    
    var rawValue: String {
      switch self {
      case .ownerId: return "owner_id"
      }
    }
    
    var fields: URLQueryItem? {
      switch self {
      case .ownerId(let fields):
        if !fields.isEmpty { return URLQueryItem(name: User.Fields.parameterName, value: fields.map(\.rawValue).joined(separator: ",")) }
      }
      
      return nil
    }
  }
}

extension List {
  public struct Includes: Codable {
    public let users: [User]?
  }
}
