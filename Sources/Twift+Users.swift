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
                      expansions: [User.Expansions] = [.pinned_tweet_id],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          expansions: expansions.map { $0.rawValue },
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
                        expansions: [User.Expansions] = [],
                        tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          expansions: expansions.map { $0.rawValue },
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
                    expansions: [User.Expansions] = [],
                    tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          expansions: expansions.map { $0.rawValue },
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
                       expansions: [User.Expansions] = [],
                       tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          expansions: expansions.map { $0.rawValue },
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
                         expansions: [User.Expansions] = [],
                         tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(userFields: userFields,
                          tweetFields: tweetFields,
                          expansions: expansions.map { $0.rawValue },
                          route: .usersByUsernames(usernames),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
}
