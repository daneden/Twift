import Foundation

extension Twift {
  /// Causes the user ID to Retweet the target Tweet
  ///
  /// Equivalent to `POST /2/users/:user_id/retweets`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to Retweet.
  ///   - userId: The user ID who you are Retweeting a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing the result of the request
  public func retweet(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<RetweetResponse> {
    let body = ["tweet_id": tweetId]
    let encodedBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    return try await call(route: .retweets(userId),
                          method: .POST,
                          body: encodedBody)
  }
  
  /// Causes the user ID to remove the Retweet of a Tweet
  ///
  /// Equivalent to `DELETE /2/users/:user_id/retweets/:tweet_id`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to remove the Retweet of.
  ///   - userId: The user ID who you are removing a the Retweet of a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing the result of the request
  public func unretweet(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<RetweetResponse> {
    return try await call(route: .retweets(userId, tweetId: tweetId),
                          method: .DELETE)
  }
  
  /// Allows you to get information about who has Retweeted a Tweet.
  ///
  /// Equivalent to `GET /2/tweets/:tweet_id/retweeted_by`
  /// - Parameters:
  ///   - tweetId: Tweet ID of the Tweet to request Retweeting users of.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing an array of  users who retweeted the target Tweet, and any associated expansions
  public func retweets(for tweetId: Tweet.ID,
                       fields: Set<User.Field> = [],
                       expansions: [User.Expansions] = [],
                       paginationToken: String? = nil,
                       maxResults: Int = 10
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    
    queryItems = queryItems + fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .retweetedBy(tweetId),
                          method: .GET,
                          queryItems: queryItems)
  }
  
  /// Returns Quote Tweets for a Tweet specified by the requested Tweet ID.
  ///
  /// Equivalent to `GET /2/tweets/:id/quote_tweets`
  /// - Parameters:
  ///   - tweetId: Unique identifier of the Tweet to request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``Tweet`` structs, requested expansions, and pagination data
  public func quoteTweets(for tweetId: Tweet.ID,
                          fields: Set<Tweet.Field> = [],
                          expansions: [Tweet.Expansions] = [],
                          paginationToken: String? = nil,
                          maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .quoteTweets(tweetId),
                          queryItems: queryItems + fieldsAndExpansions)
  }
}

/// A Twitter API response object pertaining to Retweet requests
public struct RetweetResponse: Codable {
  /// Whether or not the target tweet was retweeted as a result of this request
  public let retweeted: Bool
}
