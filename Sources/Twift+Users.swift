import Foundation

extension Twift {
  // MARK: User Lookup Methods
  
  /// Returns a variety of information about a single user specified by the requested ID.
  ///
  /// Equivalent to `GET /2/users/:id`.
  /// - Parameters:
  ///   - userId: The ID of the user to lookup.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUser(_ userId: User.ID,
                      fields: RequestFields? = nil,
                      expansions: [User.Expansions] = [.pinned_tweet_id],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .singleUserById(userId),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about a single user specified by the requested username.
  ///
  /// Equivalent to `GET /2/users/by/username/:username`.
  /// - Parameters:
  ///   - username: The screen name of the user to lookup.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUserBy(username: String,
                        fields: RequestFields? = nil,
                        expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .singleUserByUsername(username),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about the currently-authenticated user
  ///
  /// Equivalent to `GET /2/users/me`.
  /// - Parameters:
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing the ``User`` and any pinned tweets
  public func getMe(fields: RequestFields? = nil,
                    expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .me,
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about one or more users specified by the requested IDs.
  ///
  /// Equivalent to `GET /2/users`.
  /// - Parameters:
  ///   - userIds: The list of user IDs. Up to 100 are allowed in a single request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getUsers(_ userIds: [User.ID],
                       fields: RequestFields?,
                       expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .users(userIds),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about one or more users specified by the requested usernames (handles).
  ///
  /// Equivalent to `GET /2/users/by`.
  /// - Parameters:
  ///   - usernames: A list of usernames (handles) to look up. Up to 100 are allowed in a single request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getUsersBy(usernames: [String],
                         fields: RequestFields?,
                         expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .usersByUsernames(usernames),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
}
