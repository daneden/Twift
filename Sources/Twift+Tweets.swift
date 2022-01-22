import Foundation

extension Twift {
  // MARK: Tweet Lookup
  
  /// Returns a variety of information about a single Tweet specified by the requested ID.
  /// - Parameters:
  ///   - tweetId: Unique identifier of the Tweet to request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the requested Tweet and additional data objects.
  public func getTweet(_ tweetId: Tweet.ID,
                       fields: Set<Tweet.Field> = [],
                       expansions: [Tweet.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<Tweet, Tweet.Includes> {
    let queryItems = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    return try await call(route: .tweet(tweetId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns a variety of information about the Tweet specified by the requested ID or list of IDs.
  /// - Parameters:
  ///   - tweetIds: A comma separated list of Tweet IDs. Up to 100 are allowed in a single request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the requested Tweets and additional data objects.
  public func getTweets(_ tweetIds: [Tweet.ID],
                        fields: Set<Tweet.Field> = [],
                        expansions: [Tweet.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[Tweet], Tweet.Includes> {
    let queryItems = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .tweets(tweetIds),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  public enum TweetExclusion: String {
    case replies, retweets
  }
  
  // MARK: Timelines
  
  /// Returns Tweets composed by a single user, specified by the requested user ID. By default, the most recent ten Tweets are returned per request. Using pagination, the most recent 3,200 Tweets can be retrieved.
  ///
  /// Equivalent to `GET /2/users/:id/timeline`
  /// - Parameters:
  ///   - userId: Unique identifier of the Twitter account (user ID) for whom to return results.
  ///   - startTime: The oldest or earliest UTC timestamp from which the Tweets will be provided. Only the 3200 most recent Tweets are available. Timestamp is in second granularity and is inclusive (for example, 12:00:01 includes the first second of the minute). Minimum allowable time is 2010-11-06T00:00:00Z
  ///   - endTime: The newest or most recent UTC timestamp from which the Tweets will be provided. Only the 3200 most recent Tweets are available. Timestamp is in second granularity and is inclusive (for example, 12:00:01 includes the first second of the minute). Minimum allowable time is 2010-11-06T00:00:01Z
  ///   - exclude: Comma-separated list of the types of Tweets to exclude from the response. When exclude=retweets is used, the maximum historical Tweets returned is still 3200. When the exclude=replies parameter is used for any value, only the most recent 800 Tweets are available.
  ///   - sinceId: Returns results with a Tweet ID greater than (that is, more recent than) the specified 'since' Tweet ID. Only the 3200 most recent Tweets are available. The result will exclude the since_id. If the limit of Tweets has occurred since the since_id, the since_id will be forced to the oldest ID available.
  ///   - untilId: Returns results with a Tweet ID less less than (that is, older than) the specified 'until' Tweet ID. Only the 3200 most recent Tweets are available. The result will exclude the until_id. If the limit of Tweets has occurred since the until_id, the until_id will be forced to the most recent ID available.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: This parameter is used to move forwards or backwards through 'pages' of results, based on the value of the next_token or previous_token in the response. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified.
  ///   - maxResults: Specifies the number of Tweets to try and retrieve, up to a maximum of 100 per distinct request. By default, 10 results are returned if this parameter is not supplied. The minimum permitted value is 5. It is possible to receive less than the max_results per request throughout the pagination process.
  /// - Returns: A response object containing the requested Tweets and additional data objects.
  public func userTimeline(_ userId: User.ID,
                           startTime: Date? = nil,
                           endTime: Date? = nil,
                           exclude: [TweetExclusion]? = nil,
                           sinceId: Tweet.ID? = nil,
                           untilId: Tweet.ID? = nil,
                           fields: Set<Tweet.Field> = [],
                           expansions: [Tweet.Expansions] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    switch maxResults {
    case 5...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 5, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    if let exclude = exclude { queryItems.append(URLQueryItem(name: "exclude", value: exclude.map(\.rawValue).joined(separator: ","))) }
    if let sinceId = sinceId { queryItems.append(URLQueryItem(name: "since_id", value: sinceId)) }
    if let untilId = untilId { queryItems.append(URLQueryItem(name: "until_id", value: untilId)) }
    if let startTime = startTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "start_time", value: startTime)) }
    if let endTime = endTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "end_time", value: endTime)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .timeline(userId),
                          queryItems: queryItems + fieldsAndExpansions,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Returns Tweets mentioning a single user specified by the requested user ID. By default, the most recent ten Tweets are returned per request. Using pagination, up to the most recent 800 Tweets can be retrieved.
  ///
  /// Equivalent to `GET /2/users/:id/mentions`
  /// - Parameters:
  ///   - userId: Unique identifier of the Twitter account (user ID) for whom to return results.
  ///   - startTime: The oldest or earliest UTC timestamp from which the Tweets will be provided. Only the 3200 most recent Tweets are available. Timestamp is in second granularity and is inclusive (for example, 12:00:01 includes the first second of the minute). Minimum allowable time is 2010-11-06T00:00:00Z
  ///   - endTime: The newest or most recent UTC timestamp from which the Tweets will be provided. Only the 3200 most recent Tweets are available. Timestamp is in second granularity and is inclusive (for example, 12:00:01 includes the first second of the minute). Minimum allowable time is 2010-11-06T00:00:01Z
  ///   - exclude: Comma-separated list of the types of Tweets to exclude from the response. When exclude=retweets is used, the maximum historical Tweets returned is still 3200. When the exclude=replies parameter is used for any value, only the most recent 800 Tweets are available.
  ///   - sinceId: Returns results with a Tweet ID greater than (that is, more recent than) the specified 'since' Tweet ID. Only the 3200 most recent Tweets are available. The result will exclude the since_id. If the limit of Tweets has occurred since the since_id, the since_id will be forced to the oldest ID available.
  ///   - untilId: Returns results with a Tweet ID less less than (that is, older than) the specified 'until' Tweet ID. Only the 3200 most recent Tweets are available. The result will exclude the until_id. If the limit of Tweets has occurred since the until_id, the until_id will be forced to the most recent ID available.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: This parameter is used to move forwards or backwards through 'pages' of results, based on the value of the next_token or previous_token in the response. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified.
  ///   - maxResults: Specifies the number of Tweets to try and retrieve, up to a maximum of 100 per distinct request. By default, 10 results are returned if this parameter is not supplied. The minimum permitted value is 5. It is possible to receive less than the max_results per request throughout the pagination process.
  /// - Returns: A response object containing the requested Tweets and additional data objects.
  public func userMentions(_ userId: User.ID,
                           fields: Set<Tweet.Field> = [],
                           expansions: [Tweet.Expansions] = [],
                           startTime: Date? = nil,
                           endTime: Date? = nil,
                           exclude: [TweetExclusion]? = nil,
                           sinceId: Tweet.ID? = nil,
                           untilId: Tweet.ID? = nil,
                           paginationToken: String? = nil,
                           maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    switch maxResults {
    case 5...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 5, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    if let exclude = exclude { queryItems.append(URLQueryItem(name: "exclude", value: exclude.map(\.rawValue).joined(separator: ","))) }
    if let sinceId = sinceId { queryItems.append(URLQueryItem(name: "since_id", value: sinceId)) }
    if let untilId = untilId { queryItems.append(URLQueryItem(name: "until_id", value: untilId)) }
    if let startTime = startTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "start_time", value: startTime)) }
    if let endTime = endTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "end_time", value: endTime)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .mentions(userId),
                          queryItems: queryItems + fieldsAndExpansions,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
}

extension Twift {
  // MARK: Manage Tweets
  
  /// Allows a user or authenticated user ID to delete a Tweet.
  ///
  /// Equivalent to `DELETE /2/tweets/:tweet_id`
  /// - Parameter tweetId: The Tweet ID you are deleting.
  /// - Returns: A response object representing the result of this request
  public func deleteTweet(_ tweetId: Tweet.ID) async throws -> TwitterAPIData<DeleteResponse> {
    return try await call(route: .tweet(tweetId), method: .DELETE, expectedReturnType: TwitterAPIData.self)
  }
}

/// A response object pertaining to requests that delete objects
public struct DeleteResponse: Codable {
  /// Whether or not the target object was deleted as a result of the request
  public let deleted: Bool
}

extension Twift {
  // MARK: Hide/Unhide Tweets
  internal func toggleHiddenTweet(_ id: Tweet.ID, hidden: Bool) async throws -> TwitterAPIData<HiddenResponse> {
    let body = ["hidden": hidden]
    let encodedBody = try JSONSerialization.data(withJSONObject: body)
    
    return try await call(route: .tweetHidden(id),
                          method: .PUT,
                          body: encodedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
  /// Hides a reply to a Tweet.
  /// - Parameter tweetId: Unique identifier of the Tweet to hide. The Tweet must belong to a conversation initiated by the authenticating user.
  /// - Returns: A response object containing a ``HiddenResponse``
  public func hideReply(_ tweetId: Tweet.ID) async throws -> TwitterAPIData<HiddenResponse> {
    return try await toggleHiddenTweet(tweetId, hidden: true)
  }
  
  /// Unhides a reply to a Tweet.
  /// - Parameter tweetId: Unique identifier of the Tweet to unhide. The Tweet must belong to a conversation initiated by the authenticating user.
  /// - Returns: A response object containing a ``HiddenResponse``
  public func unhideReply(_ tweetId: Tweet.ID) async throws -> TwitterAPIData<HiddenResponse> {
    return try await toggleHiddenTweet(tweetId, hidden: false)
  }
}

/// A response object pertaining to requests for hiding/unhiding Tweets
public struct HiddenResponse: Codable {
  /// Whether or not the target Tweet reply was hidden as a result of the request
  public let hidden: Bool
}
