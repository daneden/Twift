import Foundation

extension Twift {
  func getURL(for route: APIRoute, queryItems: [URLQueryItem] = []) -> URL {
    var combinedQueryItems: [URLQueryItem] = []
    
    combinedQueryItems.append(contentsOf: queryItems)
    
    if let routeQueryItems = route.resolvedPath.queryItems {
      combinedQueryItems.append(contentsOf: routeQueryItems)
    }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.twitter.com"
    components.path = "/2/\(route.resolvedPath.path)"
    components.queryItems = combinedQueryItems
    
    return components.url!
  }
  
  internal func signURLRequest(
    method: HTTPMethod,
    request: inout URLRequest
  ) throws {
    if let clientCredentials = clientCredentials {
      request.oAuthSign(
        method: method.rawValue,
        consumerCredentials: clientCredentials.helperTuple(),
        userCredentials: userCredentials?.helperTuple()
      )
    } else if let bearerToken = bearerToken {
      request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    } else {
      throw TwiftError.MissingCredentialsError
    }
  }
  
  internal func buildQueryItems(userFields: [User.Fields], tweetFields: [Tweet.Fields]) -> [URLQueryItem] {
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
  public enum APIRoute {
    case tweets, me
    
    case users(_ userIds: [User.ID])
    case usersByUsernames(_ usernames: [String])
    
    case singleUserById(_ userId: User.ID)
    case singleUserByUsername(_ username: String)
    
    case following(_ userId: User.ID)
    case followers(_ userId: User.ID)
    case deleteFollow(sourceUserId: User.ID, targetUserId: User.ID)
    
    var resolvedPath: (path: String, queryItems: [URLQueryItem]?) {
      switch self {
      case .tweets:
        return (path: "tweets", queryItems: nil)
        
      case .users(let userIds):
        return (path: "users",
                queryItems: [URLQueryItem(name: "ids", value: userIds.joined(separator: ","))])
      case .usersByUsernames(let usernames):
        return (path: "users/by", queryItems: [URLQueryItem(name: "usernames", value: usernames.joined(separator: ","))])
      case .singleUserById(let userId):
        return (path: "users/\(userId)", queryItems: nil)
      case .singleUserByUsername(let username):
        return (path: "users/by/username/\(username)", queryItems: nil)
      case .me:
        return (path: "users/me", queryItems: nil)
        
      case .following(let id):
        return (path: "users/\(id)/following", queryItems: nil)
      case .followers(let id):
        return (path: "users/\(id)/followers", queryItems: nil)
      case .deleteFollow(sourceUserId: let sourceUserId, targetUserId: let targetUserId):
        return (path: "users/\(sourceUserId)/following/\(targetUserId)", queryItems: nil)
      }
    }
  }
  
  internal func decodeOrThrow<T: Codable>(decodingType: T.Type, data: Data) throws -> T {
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    return try decoder.decode(decodingType.self, from: data)
  }
}

public struct TwitterAPIData<Resource: Codable>: Codable {
  public let data: Resource
  public let errors: [TwitterAPIError]?
}

public struct TwitterAPIDataAndIncludes<Resource: Codable, Includes: Codable>: Codable {
  public let data: Resource
  public let includes: Includes?
  public let errors: [TwitterAPIError]?
}

public struct TwitterAPIDataIncludesAndMeta<Resource: Codable, Includes: Codable, Meta: Codable>: Codable {
  public let data: Resource
  public let includes: Includes?
  public let meta: Meta?
  public let errors: [TwitterAPIError]?
}

internal enum HTTPMethod: String {
  case GET, POST, DELETE
}

public struct Meta: Codable {
  public let resultCount: Int
  public let nextToken: String?
  public let previousToken: String?
}
