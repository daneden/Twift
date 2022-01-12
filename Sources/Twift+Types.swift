import Foundation

public struct OAuthToken: Codable {
  var key: String
  var secret: String
  
  enum CodingKeys: String, CodingKey {
    case key = "oauth_token"
    case secret = "oauth_token_secret"
  }
  
  func helperTuple() -> (key: String, secret: String) {
    return (key: key, secret: secret)
  }
  
  public init(key: String, secret: String) {
    self.key = key
    self.secret = secret
  }
}

protocol EntityObject: Codable {
  var start: Int { get }
  var end: Int { get }
}
