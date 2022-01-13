import Foundation

extension Twift {
  func getURL(for route: APIRoute, queryItems: [URLQueryItem] = []) -> URL {
    var combinedQueryItems: [URLQueryItem] = []
    
    if case .users(let userIds) = route,
       userIds.count > 1 {
      combinedQueryItems.append(URLQueryItem(name: "ids", value: userIds.joined(separator: ",")))
    }
    
    combinedQueryItems.append(contentsOf: queryItems)
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.twitter.com"
    components.path = "/2/\(route.resolvedPath)"
    components.queryItems = combinedQueryItems
    
    return components.url!
  }
  
  func signURLRequest(method: HTTPMethod, request: inout URLRequest) throws {
    if let clientCredentials = clientCredentials {
      request.oAuthSign(method: method.rawValue, consumerCredentials: clientCredentials.helperTuple(), userCredentials: userCredentials?.helperTuple())
    } else if let bearerToken = bearerToken {
      request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    } else {
      throw TwiftError.MissingCredentialsError
    }
  }
  
  func buildQueryItems(userFields: [User.Fields], tweetFields: [Tweet.Fields]) -> [URLQueryItem] {
    var queryItems = [
      URLQueryItem(name: "user.fields", value: userFields.map(\.rawValue).joined(separator: ",")),
      URLQueryItem(name: "tweet.fields", value: tweetFields.map(\.rawValue).joined(separator: ",")),
    ]
    
    if !tweetFields.isEmpty {
      queryItems.append(URLQueryItem(name: "expansions", value: User.Expansions.pinned_tweet_id.rawValue))
    }
    
    return queryItems
  }
}

extension Twift {
  enum APIRoute {
    case tweets, usersBy, me
    case users(_ userIds: [String])
    case usersByUsername(_ userName: String)
    
    var resolvedPath: String {
      switch self {
      case .users:
        return "users"
      case .tweets:
        return "tweets"
      case .usersBy:
        return "users/by"
      case .usersByUsername(let userName):
        return "users/by/username/\(userName)"
      case .me:
        return "users/me"
      }
    }
  }
}

public struct TwitterAPIData<Resource: Codable>: Codable {
  public let data: Resource
}

public struct TwitterAPIDataAndIncludes<Resource: Codable, Includes: Codable>: Codable {
  public let data: Resource
  public let includes: Includes?
}

public struct TwitterAPIDataIncludesAndMeta<Resource: Codable, Includes: Codable, Meta: Codable>: Codable {
  public let data: Resource
  public let includes: Includes?
  public let meta: Meta?
}

public enum HTTPMethod: String {
  case GET, POST, DELETE
}
