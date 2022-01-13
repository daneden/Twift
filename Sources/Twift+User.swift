import Foundation

extension Twift {
  // MARK: User Lookup Methods
  
  /// Equivalent to `GET /2/users/:id`.
  /// Returns a variety of information about a single user specified by the requested ID.
  /// - Parameters:
  ///   - wrappedUserID: The ID or screen name of the user to lookup.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `User`.
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUser(_ userId: User.ID,
                      userFields: [User.Fields] = [],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    let url = getURL(for: .singleUserById(userId), queryItems: queryItems)
    var userRequest = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &userRequest)

    let (data, _) = try await URLSession.shared.data(for: userRequest)
    
    return try decoder.decode(TwitterAPIDataAndIncludes.self, from: data)
  }
  
  /// Equivalent to `GET /2/users/by/username/:username`.
  /// Returns a variety of information about a single user specified by the requested username.
  /// - Parameters:
  ///   - wrappedUserID: The ID or screen name of the user to lookup.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `User`.
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUserBy(username: String,
                      userFields: [User.Fields] = [],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    let url = getURL(for: .singleUserByUsername(username), queryItems: queryItems)
    var userRequest = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &userRequest)
    
    let (data, _) = try await URLSession.shared.data(for: userRequest)
    
    return try decoder.decode(TwitterAPIDataAndIncludes.self, from: data)
  }
  
  /// Equivalent to `GET /2/users/me`.
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
  
  /// Equivalent to `GET /2/users`.
  /// Returns a variety of information about one or more users specified by the requested IDs.
  /// - Parameters:
  ///   - userIds: The list of user IDs. Up to 100 are allowed in a single request.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataAndIncludes` struct.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getUsers(_ userIds: [User.ID],
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
  
  /// Equivalent to `GET /2/users/by`.
  /// Returns a variety of information about one or more users specified by the requested usernames (handles).
  /// - Parameters:
  ///   - usernames: A list of usernames (handles) to look up. Up to 100 are allowed in a single request.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataAndIncludes` struct.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getUsersBy(usernames: [String],
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

extension Twift {
  // MARK: Follows methods
  
  /// Equivalent to `GET /2/users/:id/following`.
  /// Returns a list of users the specified user ID is following
  /// - Parameters:
  ///   - userId: The user ID whose following you would like to retreive.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataIncludesAndMeta` struct.
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getFollowing(_ userId: User.ID,
                           userFields: [User.Fields] = [],
                           tweetFields: [Tweet.Fields] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    switch maxResults {
    case 0...1000:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 1000, fieldName: "maxResults", actual: maxResults)
    }
    
    var queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    queryItems.append(URLQueryItem(name: "max_results", value: "\(maxResults)"))
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    let url = getURL(
      for: .following(userId),
      queryItems: queryItems
    )
    
    var request = URLRequest(url: url)
    try signURLRequest(method: .GET, request: &request)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    return try decoder.decode(TwitterAPIDataIncludesAndMeta.self, from: data)
  }
  
  /// Equivalent to `GET /2/users/:id/followers`.
  /// Returns a list of users who are followers of the specified user ID
  /// - Parameters:
  ///   - userId: The user ID whose followers you would like to retrieve
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `TwitterAPIDataIncludesAndMeta` struct.
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getFollowers(_ userId: User.ID,
                           userFields: [User.Fields] = [],
                           tweetFields: [Tweet.Fields] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    switch maxResults {
    case 0...1000:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 1000, fieldName: "maxResults", actual: maxResults)
    }
    
    var queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    queryItems.append(URLQueryItem(name: "max_results", value: "\(maxResults)"))
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    let url = getURL(
      for: .followers(userId),
         queryItems: queryItems
    )
    
    var request = URLRequest(url: url)
    try signURLRequest(method: .GET, request: &request)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
    return try decoder.decode(TwitterAPIDataIncludesAndMeta.self, from: data)
  }
}
