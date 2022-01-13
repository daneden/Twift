import Foundation

public enum UserID {
  case id(_: String)
  case screenName(_: String)
}

// MARK: User Lookup Methods
extension Twift {
  /// Returns a variety of information about a single user specified by the requested ID or screen name.
  /// - Parameters:
  ///   - wrappedUserID: The ID or screen name of the user to lookup.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `User`.
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUser(by wrappedUserID: UserID,
                      userFields: [User.Fields] = [],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    
    var route: APIRoute
    switch wrappedUserID {
    case .id(let userId):
      route = .singleUserById(userId)
    case .screenName(let username):
      route = .singleUserByUsername(username)
    }
    
    let url = getURL(for: route, queryItems: queryItems)
    var userRequest = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &userRequest)

    let (data, _) = try await URLSession.shared.data(for: userRequest)
    
    return try decoder.decode(TwitterAPIDataAndIncludes.self, from: data)
  }
  
  /// Returns a variety of information about the currently-authenticated user
  /// - Parameters:
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataAndIncludes` struct.
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getMe(userFields: [User.Fields] = [],
                    tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    
    let url = getURL(for: .me, queryItems: queryItems)
    var userRequest = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &userRequest)
    
    let (data, _) = try await URLSession.shared.data(for: userRequest)
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    return try decoder.decode(TwitterAPIDataAndIncludes.self, from: data)
  }
  
  /// Returns a variety of information about one or more users specified by the requested IDs.
  /// - Parameters:
  ///   - userIds: The list of user IDs. Up to 100 are allowed in a single request.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataAndIncludes` struct.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getUsers(withIds userIds: [User.ID],
                       userFields: [User.Fields] = [],
                       tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)

    let url = getURL(for: .users(userIds), queryItems: queryItems)
    var request = URLRequest(url: url)
    try signURLRequest(method: .GET, request: &request)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    return try decoder.decode(TwitterAPIDataAndIncludes.self, from: data)
  }
  
  /// Returns a variety of information about one or more users specified by the requested usernames (handles).
  /// - Parameters:
  ///   - usernames: A list of usernames (handles) to look up. Up to 100 are allowed in a single request.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataAndIncludes` struct.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  func getUsers(_ usernames: [String],
                userFields: [User.Fields] = [],
                tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    
    let url = getURL(for: .usersByUsernames(usernames), queryItems: queryItems)
    var request = URLRequest(url: url)
    try signURLRequest(method: .GET, request: &request)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    return try decoder.decode(TwitterAPIDataAndIncludes.self, from: data)
  }
}

// MARK: POST /users methods
extension Twift {
  
}
