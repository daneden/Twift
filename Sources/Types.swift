import Foundation

/// A structure containing OAuth key and secret tokens
public struct OAuthCredentials: Codable {
  /// The public OAuth key (also referred to as the OAuth application key or access token)
  public let key: String
  
  /// The private OAuth secrey (also referred to as the OAuth application secret or access token secret)
  public let secret: String
  
  /// An optional User ID
  public let userId: User.ID?
  
  /// Coding keys for decoding oauth token responses from the Twitter API
  enum CodingKeys: String, CodingKey {
    case key = "oauth_token"
    case secret = "oauth_token_secret"
    case userId = "user_id"
  }
  
  /// Initialise an OAuth token from a known key, secret, and optional user ID
  public init(key: String, secret: String, userId: String? = nil) {
    self.key = key
    self.secret = secret
    self.userId = userId
  }
}

internal protocol EntityObject: Codable {
  var start: Int { get }
  var end: Int { get }
}

internal protocol Expandable: Codable {
  associatedtype Expansions: Expansion
}

internal protocol Fielded {
  associatedtype Field: PartialKeyPath<Self>
  static func fieldName(field: Field) -> String?
  static var fieldParameterName: String { get }
}

internal protocol PrivateFielded: Fielded {
  static var privateFields: Set<Field> { get }
  static var publicFields: Set<Field> { get }
}

/// A tag entity (such as a hashtag or cashtag) found in a string, with indices in its parent string
public struct TagEntity: EntityObject {
  /// The start index for this entity
  public let start: Int
  
  /// The end index for this entity
  public let end: Int
  
  /// The UTF-8 text of the tag itself
  public let tag: String
}

/// An @username mention entity found in a string, with indices in its parent string
public struct MentionEntity: EntityObject {
  /// The start index for this entity
  public let start: Int
  
  /// The end index for this entity
  public let end: Int
  
  /// The UTF-8 text of the mentioned username
  public let username: String
}

/// Information about reasons why and/or countries where the associated content is withheld
/// More information: https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country
public struct WithheldInformation: Codable {
  /// Scopes for withheld information
  public enum Scope: String, Codable {
    /// A value indicating that the associated Tweet is under withholding restrictions
    case tweet
    
    /// A value indicating that the associated User is under withholding restrictions
    case user
  }
  
  /// A list of country codes where the associated content is withheld
  public let countryCodes: [String]
  
  /// The scope of the withheld content, either `tweet` or `user` (see ``WithheldInformationScope``)
  public let scope: Scope?
  
  /// Whether the associated content is withheld due to copyright laws
  public let copyright: Bool?
}

internal protocol Expansion {
  var rawValue: String { get }
  var fields: URLQueryItem? { get }
}
