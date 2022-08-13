import Foundation

extension Twift {
  /// Causes the user ID to Like the target Tweet.
  ///
  /// Equivalent to `POST /2/users/:user_id/likes`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to Like.
  ///   - userId: The user ID who you are liking a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing a ``LikeResponse``
  public func likeTweet(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<LikeResponse> {
    let body = ["tweet_id": tweetId]
    let encodedBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    return try await call(route: .userLikes(userId),
                          method: .POST,
                          body: encodedBody)
  }
  
  /// Causes the user ID to unlike the target Tweet.
  ///
  /// Equivalent to `DELETE /2/users/:user_id/likes/:tweet_id`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to unlike.
  ///   - userId: The user ID who you are removing Like of a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing a ``LikeResponse``
  public func unlikeTweet(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<LikeResponse> {
    return try await call(route: .deleteUserLikes(userId, tweetId: tweetId),
                          method: .DELETE)
  }
  
  /// Allows you to get information about a Tweet’s liking users.
  ///
  /// Equivalent to `GET /2/tweets/:id/liking_users`
  /// - Parameters:
  ///   - tweetId: Tweet ID of the Tweet to request liking users of.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: This parameter is used to move forwards or backwards through 'pages' of results, based on the value of the next_token or previous_token in the response.
  ///   - maxResults: Specifies the number of Tweets to try and retrieve, up to a maximum of 100 per distinct request. By default, 10 results are returned if this parameter is not supplied. The minimum permitted value is 10. It is possible to receive less than the max_results per request throughout the pagination process.
  /// - Returns: A response object containing an array of Users that like the target Tweet
  public func getLikingUsers(for tweetId: Tweet.ID,
                             fields: Set<User.Field> = [],
                             expansions: [User.Expansions] = [],
                             paginationToken: String? = nil,
                             maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    
    queryItems = queryItems + fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .likingUsers(tweetId),
                          method: .GET,
                          queryItems: queryItems)
  }
  
  /// Allows you to get information about a user’s liked Tweets.
  ///
  /// Equivalent to `GET /2/users/:id/liked_tweets`
  /// - Parameters:
  ///   - userId: User ID of the user to request liked Tweets for.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: This parameter is used to move forwards or backwards through 'pages' of results, based on the value of the next_token or previous_token in the response.
  ///   - maxResults: Specifies the number of Tweets to try and retrieve, up to a maximum of 100 per distinct request. By default, 10 results are returned if this parameter is not supplied. The minimum permitted value is 10. It is possible to receive less than the max_results per request throughout the pagination process.
  /// - Returns: A response object containing an array of Tweets liked by the target User
  public func getLikedTweets(for userId: User.ID,
                             fields: Set<Tweet.Field> = [],
                             expansions: [Tweet.Expansions] = [],
                             paginationToken: String? = nil,
                             maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    
    queryItems = queryItems + fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .likedTweets(userId),
                          method: .GET,
                          queryItems: queryItems)
  }
}

/// A response object containing information relating to Like-related API requests
public struct LikeResponse: Codable {
  /// Indicates whether the user likes the specified Tweet as a result of this request.
  public let liked: Bool
}
