import Foundation

extension Twift {
  // MARK: User Lookup Methods
  
  /// Returns a variety of information about a single user specified by the requested ID.
  ///
  /// Equivalent to `GET /2/users/:id`.
  /// - Parameters:
  ///   - wrappedUserID: The ID or screen name of the user to lookup.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataAndIncludes``.
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUser(_ userId: User.ID,
                      userFields: [User.Fields] = [],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(userFields: userFields,
                                tweetFields: tweetFields,
                                route: .singleUserById(userId),
                                expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about a single user specified by the requested username.
  ///
  /// Equivalent to `GET /2/users/by/username/:username`.
  /// - Parameters:
  ///   - wrappedUserID: The ID or screen name of the user to lookup.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataAndIncludes``.
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUserBy(username: String,
                      userFields: [User.Fields] = [],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(userFields: userFields,
                                tweetFields: tweetFields,
                                route: .singleUserByUsername(username),
                                expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about the currently-authenticated user
  ///
  /// Equivalent to `GET /2/users/me`.
  /// - Parameters:
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataAndIncludes`` struct.
  /// - Returns: A Twitter API response object containing the ``User`` and any pinned tweets
  public func getMe(userFields: [User.Fields] = [],
                    tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(userFields: userFields,
                                tweetFields: tweetFields,
                                route: .me,
                                expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about one or more users specified by the requested IDs.
  ///
  /// Equivalent to `GET /2/users`.
  /// - Parameters:
  ///   - userIds: The list of user IDs. Up to 100 are allowed in a single request.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataAndIncludes`` struct.
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getUsers(_ userIds: [User.ID],
                       userFields: [User.Fields] = [],
                       tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          route: .users(userIds),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about one or more users specified by the requested usernames (handles).
  ///
  /// Equivalent to `GET /2/users/by`.
  /// - Parameters:
  ///   - usernames: A list of usernames (handles) to look up. Up to 100 are allowed in a single request.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataAndIncludes`` struct.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getUsersBy(usernames: [String],
                userFields: [User.Fields] = [],
                tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          route: .usersByUsernames(usernames),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
}

extension Twift {
  // MARK: Follows methods
  
  /// Returns a list of users the specified user ID is following.
  ///
  /// Equivalent to `GET /2/users/:id/following`.
  /// - Parameters:
  ///   - userId: The user ID whose following you would like to retreive.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataIncludesAndMeta`` struct.
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
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
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          route: .following(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Returns a list of users who are followers of the specified user ID.
  ///
  /// Equivalent to `GET /2/users/:id/followers`.
  /// - Parameters:
  ///   - userId: The user ID whose followers you would like to retrieve
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataIncludesAndMeta`` struct.
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
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
    
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          route: .followers(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Allows a user ID to follow another user.
  ///
  /// Equivalent to `POST /2/user/:user_id/following`.
  ///
  /// If the target user does not have public Tweets, this endpoint will send a follow request.
  ///
  /// The request succeeds with no action when the authenticated user sends a request to a user they're already following, or if they're sending a follower request to a user that does not have public Tweets.
  /// - Parameters:
  ///   - sourceUserId: The authenticated user ID who you would like to initiate the follow on behalf of.
  ///   - targetUserId: The user ID of the user that you would like the `sourceUserId` to follow.
  /// - Returns: A ``FollowResponse`` indicating whether the source user is now following the target user, and whether the follow request is pending
  public func followUser(
    sourceUserId: User.ID,
    targetUserId: User.ID
  ) async throws -> TwitterAPIData<FollowResponse> {
    let body = ["target_user_id": targetUserId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .following(sourceUserId),
                          method: .POST,
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  public func unfollowUser(sourceUserId: User.ID,
                           targetUserId: User.ID
  ) async throws -> TwitterAPIData<FollowResponse> {
    return try await call(route: .deleteFollow(sourceUserId: sourceUserId, targetUserId: targetUserId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
}

extension Twift {
  // MARK: Blocks methods
  
  /// Returns a list of users who are blocked by the specified user ID.
  ///
  /// Equivalent to `GET /2/users/:id/blocking`.
  /// - Parameters:
  ///   - userId: The user ID whose followers you would like to retrieve
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned user objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned ``TwitterAPIDataIncludesAndMeta`` struct.
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getBlockedUsers(for userId: User.ID,
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
    
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          route: .blocking(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Causes the source user to block the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `POST /2/users/:id/blocking`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the block on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to block.
  /// - Returns: A ``BlockResponse`` indicating the blocked status.
  public func blockUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<BlockResponse> {
    let body = ["target_user_id": targetUserId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .blocking(sourceUserId),
                          method: .POST,
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Causes the source user to block the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `DELETE /2/users/:source_user_id/blocking/:target_user_id`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the block on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to block.
  /// - Returns: A ``BlockResponse`` indicating the blocked status.
  public func unblockUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<BlockResponse> {
    return try await call(route: .deleteBlock(sourceUserId: sourceUserId, targetUserId: targetUserId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
}
