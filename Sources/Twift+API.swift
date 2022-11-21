import Foundation

let envDict = ProcessInfo.processInfo.environment
let env = envDict["ENVIRONMENT"]
let isTestEnvironment = env == "TEST"

extension Twift {
  // MARK: Internal helper methods
  
  /// - Throws: `TwiftError.UnauthorizedForRequiredScopes` if the `self.oauthUser` is not authorized for the scope(s) the `route`-`method` combination requires.
  internal func call<T: Codable>(route: APIRoute,
                                 method: HTTPMethod = .GET,
                                 queryItems: [URLQueryItem] = [],
                                 body: Data? = nil
  ) async throws -> T {
    if let oauthUser = self.oauthUser {
      let requiredScopes = requiredScopes(for: route, method: method)
      guard requiredScopes.isSubset(of: oauthUser.scope) else {
        throw TwiftError.UnauthorizedForRequiredScopes(requiredScopes,
          missingScopes: requiredScopes.subtracting(oauthUser.scope)
        )
      }
    }
    
    if case AuthenticationType.oauth2UserAuth(_, _) = self.authenticationType {
      try await self.refreshOAuth2AccessToken()
    }
    
    let url = getURL(for: route, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    if let body = body {
      request.httpBody = body
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    signURLRequest(method: method, body: body, request: &request)

    let (data, _) = try await URLSession.shared.data(for: request)
    
    return try decodeOrThrow(decodingType: T.self, data: data)
  }
  
  internal func fieldsAndExpansions<T: Expandable & Fielded>(for type: T.Type,
                                                             fields: Set<T.Field>,
                                                             expansions: [T.Expansions]
  ) -> [URLQueryItem] {
    var queryItems: [URLQueryItem] = []
    
    if !fields.isEmpty { queryItems.append(URLQueryItem(name: T.fieldParameterName, value: fields.compactMap { T.fieldName(field: $0) }.joined(separator: ","))) }
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
    components.host = isTestEnvironment ? "stoplight.io" : "api.twitter.com"
  
    if isTestEnvironment {
      components.path = "/mocks/dte/twitter-v2-api-spec/54953920\(route.resolvedPath.path)"
    } else {
      components.path = "\(route.resolvedPath.path)"
    }
    
    components.queryItems = combinedQueryItems

    var allowedCharacters = CharacterSet.urlQueryAllowed
    allowedCharacters.remove(charactersIn: ":()")
    components.percentEncodedQuery = components.query?.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    
    return components.url!
  }
  
  internal func signURLRequest(method: HTTPMethod, body: Data? = nil, request: inout URLRequest) {
    switch authenticationType {
    case .appOnly(let bearerToken):
      request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    case .userAccessTokens(let clientCredentials, let userCredentials):
      request.oAuthSign(
        method: method.rawValue,
        body: body,
        consumerCredentials: clientCredentials,
        userCredentials: userCredentials
      )
    case .oauth2UserAuth(let oauthUser, _):
      request.addValue("Bearer \(oauthUser.accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    request.httpMethod = method.rawValue
  }
  
  /// For the given `APIRoute` and `HTTPMethod`, returns a `Set<OAuth2Scope>` listing the “OAuth 2.0 scopes required by this endpoint” specified in the Twitter API v2 documentation.
  /// 
  /// - Parameter route: The API route of the Twitter API v2 endpoint.
  /// - Parameter method: The HTTP method of the Twitter API v2 endpoint.
  /// - Returns: A set of scopes required to use the Twitter API v2 endpoint
  internal func requiredScopes(for route: APIRoute, method: HTTPMethod) -> Set<OAuth2Scope> {
    switch method {
      case .GET: return requiredScopesForGETRoute(route)
      case .POST: return requiredScopesForPOSTRoute(route)
      case .PUT: return requiredScopesForPUTRoute(route)
      case .DELETE: return requiredScopesForDELETERoute(route)
    }
  }
  
  /// Private helper method for `requiredScopes(for:, method:)`— handles the `HTTPMethod.GET` cases.
  fileprivate func requiredScopesForGETRoute(_ route: APIRoute) -> Set<OAuth2Scope> {
    switch route {
    case .tweet(_),
          .tweets(_),
          .timeline(_),
          .mentions(_),
          .reverseChronologicalTimeline(_):
      return [ .tweetRead, .usersRead ]
    case .users(_),
          .usersByUsernames(_),
          .singleUserById(_),
          .singleUserByUsername(_),
          .me:
      return [ .tweetRead, .usersRead ]
    case .following(_),
          .followers(_):
      return [ .tweetRead, .usersRead, .followsRead ]
    case .blocking(_):
      return [ .tweetRead, .usersRead, .blockRead ]
    case .muting(_):
      return [ .tweetRead, .usersRead, .muteRead ]
    case .volumeStream,
          .filteredStream,
          .filteredStreamRules:
      return [] // no scopes listed in API docs
    case .searchRecent:
      return [ .tweetRead, .usersRead ]
    case .searchAll:
      return [] // no scopes listed in API docs; seems to require only Academic Research access
    case .likingUsers(_),
          .likedTweets(_):
      return [ .tweetRead, .usersRead, .likeRead ]
    case .retweetedBy(_),
          .quoteTweets(_):
      return [ .tweetRead, .usersRead ]
    case .list(_),
          .userOwnedLists(_),
          .listTweets(_),
          .userListMemberships(_),
          .listMembers(_),
          .listFollowers(_),
          .userFollowingLists(_, _),
          .userPinnedLists(_, _):
      return [ .tweetRead, .usersRead, .listRead ]
    case .spaces(_, _),
          .spacesByCreatorIds,
          .searchSpaces:
      return [ .tweetRead, .usersRead, .spaceRead ]
    case .bookmarks(_):
      return [ .tweetRead, .usersRead, .bookmarkRead ]
    default:
      fatalError("Route \(route) not valid for HTTP GET method.")
    }
  }
  
  /// Private helper method for `requiredScopes(for:, method:)`— handles the `HTTPMethod.POST` cases.
  fileprivate func requiredScopesForPOSTRoute(_ route: APIRoute) -> Set<OAuth2Scope> {
    switch route {
    case .tweets(_):
      return  [ .tweetRead, .usersRead, .tweetWrite ]
    case .following(_):
      return [ .tweetRead, .usersRead, .followsWrite ]
    case .blocking(_):
      return [ .tweetRead, .usersRead, .blockWrite ]
    case .muting(_):
      return [ .tweetRead, .usersRead, .muteWrite ]
    case .filteredStreamRules:
      return [] // no scopes listed in API docs
    case .userLikes(_):
      return [ .tweetRead, .usersRead, .likeWrite ]
    case .retweets(_, _):
      return [ .tweetRead, .usersRead, .tweetWrite ]
    case .listMembers(_),
          .userFollowingLists(_, _),
          .userPinnedLists(_, _):
      return [ .tweetRead, .usersRead, .listWrite ]
    case .createList:
      return [ .tweetRead, .usersRead, .listRead, .listWrite ]
    case .bookmarks(_):
      return [ .tweetRead, .usersRead, .bookmarkWrite ]
    default:
      fatalError("Route \(route) not valid for HTTP POST method.")
    }
  }
  
  /// /// Private helper method for `requiredScopes(for:, method:)`— handles the `HTTPMethod.PUT` cases.
  fileprivate func requiredScopesForPUTRoute(_ route: APIRoute) -> Set<OAuth2Scope> {
    switch route {
    case .tweetHidden(_):
      return [ .tweetRead, .usersRead, .tweetModerateWrite ]
    case .list(_):
      return [ .tweetRead, .usersRead, .listWrite ]
    default:
      fatalError("Route \(route) not valid for HTTP PUT method.")
    }
  }
  
  /// /// Private helper method for `requiredScopes(for:, method:)`— handles the `HTTPMethod.DELETE` cases.
  fileprivate func requiredScopesForDELETERoute(_ route: APIRoute) -> Set<OAuth2Scope> {
    switch route {
    case .tweet(_):
      return  [ .tweetRead, .usersRead, .tweetWrite ]
    case .deleteFollow(_, _):
      return [ .tweetRead, .usersRead, .followsWrite ]
    case .deleteBlock(_, _):
      return [ .tweetRead, .usersRead, .blockWrite ]
    case .deleteMute(_, _):
      return [ .tweetRead, .usersRead, .muteWrite ]
    case .deleteUserLikes(_, _):
      return [ .tweetRead, .usersRead, .likeWrite ]
    case .retweets(_, _):
      return [ .tweetRead, .usersRead, .tweetWrite ]
    case .list(_),
          .removeListMember(_, _),
          .userFollowingLists(_, _),
          .userPinnedLists(_, _):
      return [ .tweetRead, .usersRead, .listWrite ]
    case .deleteBookmark(_, _):
      return [ .tweetRead, .usersRead, .bookmarkWrite ]
    default:
      fatalError("Route \(route) not valid for HTTP DELETE method.")
    }
  }
}

extension Space {
  internal enum APISubpath: String {
    case buyers, tweets
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
    
    case tweets(_ ids: [Tweet.ID] = [])
    case tweet(_ id: Tweet.ID)
    case tweetHidden(_ id: Tweet.ID)
    
    case timeline(_ userId: User.ID)
    case mentions(_ userId: User.ID)
    case reverseChronologicalTimeline(_ userId: User.ID)
    
    case volumeStream
    case filteredStream
    case filteredStreamRules
    case searchRecent
    case searchAll
    
    case userLikes(_ userId: User.ID)
    case deleteUserLikes(_ userId: User.ID, tweetId: Tweet.ID)
    case likingUsers(_ tweetId: Tweet.ID)
    case likedTweets(_ userId: User.ID)
    
    case retweets(_ userId: User.ID, tweetId: Tweet.ID? = nil)
    case retweetedBy(_ tweetId: Tweet.ID)
    
    case quoteTweets(_ tweetId: Tweet.ID)
    
    case list(_ listId: List.ID)
    case listTweets(_ listId: List.ID)
    case listFollowers(_ listId: List.ID)
    case userOwnedLists(_ userId: User.ID)
    case userListMemberships(_ userId: User.ID)
    case listMembers(_ listId: List.ID)
    case removeListMember(_ listId: List.ID, userId: User.ID)
    case userFollowingLists(_ userId: User.ID, listId: List.ID? = nil)
    case userPinnedLists(_ userId: User.ID, listId: List.ID? = nil)
    case createList
    
    case spaces(_ id: Space.ID? = nil, subpath: Space.APISubpath? = nil)
    case searchSpaces
    case spacesByCreatorIds
    
    case mediaMetadataCreate
    
    case bookmarks(_ userId: User.ID)
    case deleteBookmark(userId: User.ID, tweetId: Tweet.ID)
    
    var resolvedPath: (path: String, queryItems: [URLQueryItem]?) {
      switch self {
      case .tweet(let id):
        return (path: "/2/tweets/\(id)", queryItems: nil)
      case .tweets(let ids):
        if ids.isEmpty {
          return (path: "/2/tweets", queryItems: nil)
        } else {
          return (path: "/2/tweets",
                  queryItems: [URLQueryItem(name: "ids", value: ids.map(\.trimmed).joined(separator: ","))])
        }
      case .tweetHidden(let id):
        return (path: "/2/tweets/\(id)/hidden", queryItems: nil)
        
      case .timeline(let id):
        return (path: "/2/users/\(id)/tweets", queryItems: nil)
      case .mentions(let id):
        return (path: "/2/users/\(id)/mentions", queryItems: nil)
      case .reverseChronologicalTimeline(let id):
        return (path: "/2/users/\(id)/timelines/reverse_chronological", queryItems: nil)
        
      case .users(let ids):
        return (path: "/2/users",
                queryItems: [URLQueryItem(name: "ids", value: ids.map(\.trimmed).joined(separator: ","))])
      case .usersByUsernames(let usernames):
        return (path: "/2/users/by", queryItems: [URLQueryItem(name: "usernames", value: usernames.map(\.trimmed).joined(separator: ","))])
      case .singleUserById(let userId):
        return (path: "/2/users/\(userId)", queryItems: nil)
      case .singleUserByUsername(let username):
        return (path: "/2/users/by/username/\(username)", queryItems: nil)
      case .me:
        return (path: "/2/users/me", queryItems: nil)
        
      case .following(let id):
        return (path: "/2/users/\(id)/following", queryItems: nil)
      case .followers(let id):
        return (path: "/2/users/\(id)/followers", queryItems: nil)
      case .deleteFollow(sourceUserId: let sourceUserId, targetUserId: let targetUserId):
        return (path: "/2/users/\(sourceUserId)/following/\(targetUserId)", queryItems: nil)
        
      case .blocking(let id):
        return (path: "/2/users/\(id)/blocking", queryItems: nil)
      case .deleteBlock(let sourceUserId, let targetUserId):
        return (path: "/2/users/\(sourceUserId)/blocking/\(targetUserId)", queryItems: nil)
        
      case .muting(let id):
        return (path: "/2/users/\(id)/muting", queryItems: nil)
      case .deleteMute(let sourceUserId, let targetUserId):
        return (path: "/2/users/\(sourceUserId)/muting/\(targetUserId)", queryItems: nil)
        
      case .volumeStream:
        return (path: "/2/tweets/sample/stream", queryItems: nil)
      case .filteredStream:
        return (path: "/2/tweets/search/stream", queryItems: nil)
      case .filteredStreamRules:
        return (path: "/2/tweets/search/stream/rules", queryItems: nil)
      case .searchRecent:
        return (path: "/2/tweets/search/recent", queryItems: nil)
      case .searchAll:
        return (path: "/2/tweets/search/all", queryItems: nil)
        
      case .userLikes(let id):
        return (path: "/2/users/\(id)/likes", queryItems: nil)
      case .deleteUserLikes(let userId, let tweetId):
        return (path: "/2/users/\(userId)/likes/\(tweetId)", queryItems: nil)
      case .likingUsers(let id):
        return (path: "/2/tweets/\(id)/liking_users", queryItems: nil)
      case .likedTweets(let id):
        return (path: "/2/users/\(id)/liked_tweets", queryItems: nil)
        
      case .retweets(let userId, let tweetId):
        if let tweetId = tweetId {
          return (path: "/2/users/\(userId)/retweets/\(tweetId)", queryItems: nil)
        } else {
          return (path: "/2/users/\(userId)/retweets", queryItems: nil)
        }
      case .retweetedBy(let id):
        return (path: "/2/tweets/\(id)/retweeted_by", queryItems: nil)
        
      case .quoteTweets(let id):
        return (path: "/2/tweets/\(id)/quote_tweets", queryItems: nil)
        
      case .list(let id):
        return (path: "/2/lists/\(id)", queryItems: nil)
      case .listTweets(let id):
        return (path: "/2/lists/\(id)/tweets", queryItems: nil)
      case .listFollowers(let id):
        return (path: "/2/lists/\(id)/followers", queryItems: nil)
      case .userOwnedLists(let id):
        return (path: "/2/users/\(id)/owned_lists", queryItems: nil)
      case .userListMemberships(let id):
        return (path: "/2/users/\(id)/list_memberships", queryItems: nil)
      case .listMembers(let id):
        return (path: "/2/lists/\(id)/members", queryItems: nil)
      case .removeListMember(let listId, let userId):
        return (path: "/2/lists/\(listId)/members/\(userId)", queryItems: nil)
        
      case .userPinnedLists(let userId, let listId):
        if let listId = listId {
          return (path: "/2/users/\(userId)/pinned_lists/\(listId)", queryItems: nil)
        } else {
          return (path: "/2/users/\(userId)/pinned_lists", queryItems: nil)
        }
      case .createList:
          return (path: "/2/lists", queryItems: nil)
      case .userFollowingLists(let userId, let listId):
        if let listId = listId {
          return (path: "/2/users/\(userId)/followed_lists/\(listId)", queryItems: nil)
        } else {
          return (path: "/2/users/\(userId)/followed_lists", queryItems: nil)
        }
        
      case .spaces(let id, let subpath):
        if let id = id {
          return (path: "/2/spaces/\(id)\(subpath == nil ? "" : "/\(subpath!.rawValue)")", queryItems: nil)
        } else {
          return (path: "/2/spaces/", queryItems: nil)
        }
        
      case .searchSpaces:
        return (path: "/2/spaces/search", queryItems: nil)
      case.spacesByCreatorIds:
        return (path: "/2/spaces/by/creator_ids", queryItems: nil)
        
      case .mediaMetadataCreate:
        return (path: "/1.1/media/metadata/create.json", queryItems: nil)
        
      case .bookmarks(let userId):
        return (path: "/2/users/\(userId)/bookmarks", queryItems: nil)
      case .deleteBookmark(let userId, let tweetId):
        return (path: "/2/users/\(userId)/bookmarks/\(tweetId)", queryItems: nil)
      }
    }
  }
  
  internal func decodeOrThrow<T: Codable>(decodingType: T.Type, data: Data) throws -> T {
    guard let result = try? decoder.decode(decodingType.self, from: data) else {
      if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
      
      throw TwiftError.UnknownError(String(data: data, encoding: .utf8))
    }
    
    return result
  }
}

/// The response object from the Twitter API containing the requested object(s) in the `data` property
public struct TwitterAPIData<Resource: Codable>: Codable {
  /// The requested object(s)
  public let data: Resource
  
  /// Any errors associated with the request
  public let errors: [TwitterAPIError]?
}

/// The response object from the Twitter API containing the requested object(s) in the `data` property
public struct TwitterAPIDataAndMeta<Resource: Codable, Meta: Codable>: Codable {
  /// The requested object(s)
  public let data: Resource?
  
  /// The meta information for the request, including pagination information
  public let meta: Meta?
  
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
  case GET, POST, DELETE, PUT
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
