import Foundation

extension Twift {
  // MARK: Internal helper methods
  internal func call<T: Codable>(route: APIRoute,
                                 method: HTTPMethod = .GET,
                                 queryItems: [URLQueryItem] = [],
                                 body: Data? = nil,
                                 expectedReturnType: T.Type
  ) async throws -> T {
    let url = getURL(for: route, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    if let body = body {
      request.httpBody = body
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    try signURLRequest(method: method, request: &request)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    return try decodeOrThrow(decodingType: T.self, data: data)
  }
  
  internal func fieldsAndExpansions<T: Expandable & Fielded>(for type: T.Type,
                                                             fields: Set<T.Fields>,
                                                             expansions: [T.Expansions]
  ) -> [URLQueryItem] {
    var queryItems: [URLQueryItem] = []
    
    if !fields.isEmpty { queryItems.append(URLQueryItem(name: T.Fields.parameterName, value: fields.map(\.rawValue).joined(separator: ","))) }
    if !expansions.isEmpty { queryItems.append(URLQueryItem(name: "expansions", value: expansions.map(\.rawValue).joined(separator: ","))) }
    
    for expansion in expansions {
      if let fields = expansion.fields { queryItems.append(fields) }
    }
    
    return queryItems
  }
}

extension Twift {
  internal func getURL(for route: APIRoute, queryItems: [URLQueryItem] = []) -> URL {
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
    if let bearerToken = bearerToken {
      request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    } else if let clientCredentials = clientCredentials {
      request.oAuthSign(
        method: method.rawValue,
        consumerCredentials: clientCredentials.helperTuple(),
        userCredentials: userCredentials?.helperTuple()
      )
    } else {
      throw TwiftError.MissingCredentialsError
    }
  }
}

extension Twift {
  internal enum APIRoute {
    case me
    
    case users(_ userIds: [User.ID])
    case usersByUsernames(_ usernames: [String])
    
    case singleUserById(_ userId: User.ID)
    case singleUserByUsername(_ username: String)
    
    case following(_ userId: User.ID)
    case followers(_ userId: User.ID)
    case deleteFollow(sourceUserId: User.ID, targetUserId: User.ID)
    
    case blocking(_ userId: User.ID)
    case deleteBlock(sourceUserId: User.ID, targetUserId: User.ID)
    
    case muting(_ userId: User.ID)
    case deleteMute(sourceUserId: User.ID, targetUserId: User.ID)
    
    case tweets(_ ids: [Tweet.ID])
    case tweet(_ id: Tweet.ID)
    
    case timeline(_ userId: User.ID)
    case mentions(_ userId: User.ID)
    
    case volumeStream
    
    var resolvedPath: (path: String, queryItems: [URLQueryItem]?) {
      switch self {
      case .tweet(let id):
        return (path: "tweets/\(id)", queryItems: nil)
      case .tweets(let ids):
        return (path: "tweets",
                queryItems: [URLQueryItem(name: "ids", value: ids.map(\.trimmed).joined(separator: ","))])
        
      case .timeline(let id):
        return (path: "users/\(id)/tweets", queryItems: nil)
      case .mentions(let id):
        return (path: "users/\(id)/mentions", queryItems: nil)
        
      case .users(let ids):
        return (path: "users",
                queryItems: [URLQueryItem(name: "ids", value: ids.map(\.trimmed).joined(separator: ","))])
      case .usersByUsernames(let usernames):
        return (path: "users/by", queryItems: [URLQueryItem(name: "usernames", value: usernames.map(\.trimmed).joined(separator: ","))])
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
        
      case .blocking(let id):
        return (path: "users/\(id)/blocking", queryItems: nil)
      case .deleteBlock(let sourceUserId, let targetUserId):
        return (path: "users/\(sourceUserId)/blocking/\(targetUserId)", queryItems: nil)
        
      case .muting(let id):
        return (path: "users/\(id)/muting", queryItems: nil)
      case .deleteMute(let sourceUserId, let targetUserId):
        return (path: "users/\(sourceUserId)/muting/\(targetUserId)", queryItems: nil)
        
      case .volumeStream:
        return (path: "tweets/sample/stream", queryItems: nil)
      }
    }
  }
  
  internal func decodeOrThrow<T: Codable>(decodingType: T.Type, data: Data) throws -> T {
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    if let error = try? decoder.decode(TwitterAPIManyErrors.self, from: data) { throw error }
    return try decoder.decode(decodingType.self, from: data)
  }
}

/// The response object from the Twitter API containing the requested object(s) in the `data` property
public struct TwitterAPIData<Resource: Codable>: Codable {
  /// The requested object(s)
  public let data: Resource
  
  /// Any errors associated with the request
  public let errors: [TwitterAPIError]?
}

/// A response object from the Twitter API containing the requested object(s) in the `data` property, and expansions in the `includes` property
public struct TwitterAPIDataAndIncludes<Resource: Codable, Includes: Codable>: Codable {
  /// The requested object(s)
  public let data: Resource
  
  /// Any requested expansions
  public let includes: Includes?
  
  /// Any errors associated with the request
  public let errors: [TwitterAPIError]?
}

/// A response object from the Twitter API containing the requested object(s) in the `data` property,  expansions in the `includes` property, and additional information (such as pagination tokens) in the `meta` property
public struct TwitterAPIDataIncludesAndMeta<Resource: Codable, Includes: Codable, Meta: Codable>: Codable {
  /// The requested object(s)
  public let data: Resource
  
  /// Any requested expansions
  public let includes: Includes?
  
  /// The meta information for the request, including pagination information
  public let meta: Meta?
  
  /// Any errors associated with the request
  public let errors: [TwitterAPIError]?
}

internal enum HTTPMethod: String {
  case GET, POST, DELETE
}

/// An object containing pagination information for paginated requests
public struct Meta: Codable {
  /// The number of results in this page
  public let resultCount: Int
  
  /// The pagination token for the next page of results, if any
  public let nextToken: String?
  
  /// The pagination token for the previous page of results, if any
  public let previousToken: String?
}
