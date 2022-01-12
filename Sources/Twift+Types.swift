import Foundation

struct OAuthToken: Codable {
  var key: String
  var secret: String
  
  enum CodingKeys: String, CodingKey {
    case key = "oauth_token"
    case secret = "oauth_token_secret"
  }
  
  func helperTuple() -> (key: String, secret: String) {
    return (key: key, secret: secret)
  }
}

enum HTTPMethod: String {
  case GET, POST, DELETE
}
