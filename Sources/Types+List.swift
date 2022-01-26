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
  /// Additional fields that can be requested on the ``List`` object
  public typealias Field = PartialKeyPath<Self>
  
  static internal func fieldName(field: PartialKeyPath<List>) -> String? {
    switch field {
    case \.createdAt: return "created_at"
    case \.description: return "description"
    case \.followerCount: return "follower_count"
    case \.memberCount: return "member_count"
    case \.private: return "private"
    case \.ownerId: return "owner_id"
    default: return nil
    }
  }
  
  static internal var fieldParameterName = "list.fields"
}

extension List: Expandable {
  /// Fields that can be expanded on the ``List`` type
  public enum Expansions: Expansion {
    /// The User object for the list’s owner
    case ownerId(fields: Set<User.Field>)
    
    internal var rawValue: String {
      switch self {
      case .ownerId: return "owner_id"
      }
    }
    
    internal var fields: URLQueryItem? {
      switch self {
      case .ownerId(let fields):
        if !fields.isEmpty { return URLQueryItem(name: User.fieldParameterName, value: fields.compactMap { User.fieldName(field: $0) }.joined(separator: ",")) }
      }
      
      return nil
    }
  }
}

extension List {
  /// Expanded objects included alongside the ``List``
  public struct Includes: Codable {
    /// The users expanded with this List. Since ``List.Expansions`` contains only `ownerId`, this will  contain the expanded owner User object.
    public let users: [User]?
  }
}
