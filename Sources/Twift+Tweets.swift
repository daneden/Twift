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
                          queryItems: queryItems)
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
                          queryItems: queryItems)
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
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    if let exclude = exclude { queryItems.append(URLQueryItem(name: "exclude", value: exclude.map(\.rawValue).joined(separator: ","))) }
    if let sinceId = sinceId { queryItems.append(URLQueryItem(name: "since_id", value: sinceId)) }
    if let untilId = untilId { queryItems.append(URLQueryItem(name: "until_id", value: untilId)) }
    if let startTime = startTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "start_time", value: startTime)) }
    if let endTime = endTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "end_time", value: endTime)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .timeline(userId),
                          queryItems: queryItems + fieldsAndExpansions)
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
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    if let exclude = exclude { queryItems.append(URLQueryItem(name: "exclude", value: exclude.map(\.rawValue).joined(separator: ","))) }
    if let sinceId = sinceId { queryItems.append(URLQueryItem(name: "since_id", value: sinceId)) }
    if let untilId = untilId { queryItems.append(URLQueryItem(name: "until_id", value: untilId)) }
    if let startTime = startTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "start_time", value: startTime)) }
    if let endTime = endTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "end_time", value: endTime)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .mentions(userId),
                          queryItems: queryItems + fieldsAndExpansions)
  }
  
  /// Allows you to retrieve a collection of the most recent Tweets and Retweets posted by you and users you follow. This endpoint returns up to the last 3200 Tweets.
  ///
  /// Equivalent to `GET /2/users/:id/timelines/reverse_chronological`
  /// - Parameters:
  ///   - userId: Unique identifier of the user that is requesting their chronological home timeline.
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
  public func reverseChronologicalTimeline(_ userId: User.ID,
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
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    if let exclude = exclude { queryItems.append(URLQueryItem(name: "exclude", value: exclude.map(\.rawValue).joined(separator: ","))) }
    if let sinceId = sinceId { queryItems.append(URLQueryItem(name: "since_id", value: sinceId)) }
    if let untilId = untilId { queryItems.append(URLQueryItem(name: "until_id", value: untilId)) }
    if let startTime = startTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "start_time", value: startTime)) }
    if let endTime = endTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "end_time", value: endTime)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .reverseChronologicalTimeline(userId),
                          queryItems: queryItems + fieldsAndExpansions)
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
    return try await call(route: .tweet(tweetId), method: .DELETE)
  }
  
  /// Creates a Tweet on behalf of an authenticated user.
  /// - Parameter tweet: The payload of the post Tweet request
  /// - Returns: A data object with the newly-created Tweet's ID and text
  @discardableResult
  public func postTweet(_ tweet: MutableTweet) async throws -> TwitterAPIData<PostTweetResponse> {
    let body = try encoder.encode(tweet)
    return try await call(route: .tweets(),
                          method: .POST,
                          body: body)
  }
}

/// A response object containing the newly-posted Tweet's ID and text content
public struct PostTweetResponse: Codable {
  /// The unique ID of the new Tweet
  public let id: Tweet.ID
  
  /// The text content of the new Tweet
  public let text: String
}

/// A mutable Tweet object for creating new Tweets via the `postTweet` method
public struct MutableTweet: Codable {
  /// Text of the Tweet being created. This field is required if `media.mediaIds` is not present.
  public var text: String?
  
  /// A JSON object that contains media information being attached to created Tweet. This is mutually exclusive from Quote Tweet ID and Poll.
  public var media: MutableMedia?
  
  /// A JSON object that contains options for a Tweet with a poll. This is mutually exclusive from Media and Quote Tweet ID.
  public var poll: MutablePoll?
  
  /// Link to the Tweet being quoted.
  public var quoteTweetId: Tweet.ID?
  
  /// Information about the Tweet this Tweet is replying to
  public var reply: Reply?
  
  /// Settings to indicate who can reply to the Tweet. Options include "mentionedUsers" and "following". If the field isn’t specified, it will default to everyone.
  public var replySettings: Tweet.ReplyAudience?
  
  /// An object describing how to form a reply to a Tweet
  public struct Reply: Codable {
    /// An array of User IDs to exclude from the replying Tweet
    public var excludeReplyUserIds: [User.ID]?
    
    /// The ID of the Tweet that this Tweet is replying to
    public var inReplyToTweetId: Tweet.ID
    
    public init(inReplyToTweetId: Tweet.ID, excludeReplyUserIds: [User.ID]? = nil) {
      self.inReplyToTweetId = inReplyToTweetId
      self.excludeReplyUserIds = excludeReplyUserIds
    }
  }
  
  public init(text: String? = nil,
              media: MutableMedia? = nil,
              poll: MutablePoll? = nil,
              quoteTweetId: Tweet.ID? = nil,
              reply: Reply? = nil,
              replySettings: Tweet.ReplyAudience? = nil) {
    self.text = text
    self.media = media
    self.poll = poll
    self.quoteTweetId = quoteTweetId
    self.reply = reply
    self.replySettings = replySettings
  }
}

/// A mutable Media object for posting media with `MutableTweet`
public struct MutableMedia: Codable {
  /// A list of Media IDs being attached to the Tweet.
  public var mediaIds: [Media.ID]?
  
  /// A list of User IDs being tagged in the Tweet with Media. If the user you're tagging doesn't have photo-tagging enabled, their names won't show up in the list of tagged users even though the Tweet is successfully created.
  public var taggedUserIds: [User.ID]?
  
  public init(mediaIds: [Media.ID], taggedUserIds: [User.ID]? = nil) {
    self.mediaIds = mediaIds
    self.taggedUserIds = taggedUserIds
  }
}

/// A mutable Poll object for posting polls with `MutableTweet`
public struct MutablePoll: Codable {
  /// Duration of the poll in minutes for a Tweet with a poll.
  public var durationMinutes: Int
  
  /// A list of poll options for a Tweet with a poll.
  public var options: [String]
  
  /// Initialize a new ``MutablePoll`` with the specified options and duration. This initializer throws if there are less than 2 or more than 4 poll options.
  public init(options: [String], durationMinutes: Int = 60 * 24) throws {
    guard options.count > 1 && options.count <= 4 else {
      throw TwiftError.RangeOutOfBoundsError(min: 2, max: 4, fieldName: "options.count", actual: options.count)
    }
    self.options = options
    self.durationMinutes = durationMinutes
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
                          body: encodedBody)
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
