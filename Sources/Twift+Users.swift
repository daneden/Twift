import Foundation

extension Twift {
  // MARK: User Lookup Methods
  
  /// Returns a variety of information about a single user specified by the requested ID.
  ///
  /// Equivalent to `GET /2/users/:id`.
  /// - Parameters:
  ///   - userId: The ID of the user to lookup.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUser(_ userId: User.ID,
                      fields: Set<User.Field> = [],
                      expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .singleUserById(userId),
                          queryItems: queryItems)
  }
  
  /// Returns a variety of information about a single user specified by the requested username.
  ///
  /// Equivalent to `GET /2/users/by/username/:username`.
  /// - Parameters:
  ///   - username: The screen name of the user to lookup.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing the User and any pinned tweets
  public func getUserBy(username: String,
                        fields: Set<User.Field> = [],
                        expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .singleUserByUsername(username),
                          queryItems: queryItems)
  }
  
  /// Returns a variety of information about the currently-authenticated user
  ///
  /// Equivalent to `GET /2/users/me`.
  /// - Parameters:
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing the ``User`` and any pinned tweets
  public func getMe(fields: Set<User.Field> = [],
                    expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
    let queryItems = fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .me,
                          queryItems: queryItems)
  }
  
  /// Returns a variety of information about one or more users specified by the requested IDs.
  ///
  /// Equivalent to `GET /2/users`.
  /// - Parameters:
  ///   - userIds: The list of user IDs. Up to 100 are allowed in a single request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing an array of `User` structs and any pinned tweets in the `includes` property
  public func getUsers(_ userIds: [User.ID],
                       fields: Set<User.Field> = [],
                       expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    let queryItems = fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .users(userIds),
                          queryItems: queryItems)
  }
  
  /// Returns a variety of information about one or more users specified by the requested usernames (handles).
  ///
  /// Equivalent to `GET /2/users/by`.
  /// - Parameters:
  ///   - usernames: A list of usernames (handles) to look up. Up to 100 are allowed in a single request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getUsersBy(usernames: [String],
                         fields: Set<User.Field> = [],
                         expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    let queryItems = fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .usersByUsernames(usernames),
                          queryItems: queryItems)
  }
}
