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

public struct TagEntity: EntityObject {
  let start: Int
  let end: Int
  let tag: String
}
