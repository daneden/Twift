import Foundation

public struct OAuthCredentials: Codable {
  var key: String
  var secret: String
  public var userId: String?
  
  enum CodingKeys: String, CodingKey {
    case key = "oauth_token"
    case secret = "oauth_token_secret"
    case userId = "user_id"
  }
  
  internal func helperTuple() -> (key: String, secret: String) {
    return (key: key, secret: secret)
  }
  
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
  static var expansions: [Expansion] { get }
}

public struct TagEntity: EntityObject {
  let start: Int
  let end: Int
  let tag: String
}

public struct MentionEntity: EntityObject {
  let start: Int
  let end: Int
  let username: String
}

/// Information about reasons why and/or countries where the associated content is withheld
/// More information: https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country
public struct WithheldInformation: Codable {
  /// Scopes for withheld information
  public enum Scope: String, Codable {
    case tweet, user
  }
  
  /// A list of country codes where the associated content is withheld
  public let countryCodes: [String]
  
  /// The scope of the withheld content, either `tweet` or `user` (see ``WithheldInformationScope``)
  public let scope: Scope?
  public let copyright: Bool?
}

typealias Expansion = String
