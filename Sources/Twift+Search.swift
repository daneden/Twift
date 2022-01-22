import Foundation

extension Twift {
  /// The recent search endpoint returns Tweets from the last seven days that match a search query.
  /// - Parameters:
  ///   - query: One query for matching Tweets. You can learn how to build this query by reading Twitter's [build a query guide](https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query).
  /// If you have Essential or Elevated access, you can use the Basic operators when building your query and can make queries up to 512 characters long. If you have been approved for Academic Research access, you can use all available operators and can make queries up to 1,024 characters long.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - endTime: The newest, most recent UTC timestamp to which the Tweets will be provided. Timestamp is in second granularity and is exclusive (for example, 12:00:01 excludes the first second of the minute). By default, a request will return Tweets from as recent as 30 seconds ago if you do not include this parameter.
  ///   - startTime: The oldest UTC timestamp (from most recent seven days) from which the Tweets will be provided. Timestamp is in second granularity and is inclusive (for example, 12:00:01 includes the first second of the minute). If included with the same request as a `sinceId` parameter, only `sinceId` will be used. By default, a request will return Tweets from up to seven days ago if you do not include this parameter.
  ///   - maxResults: The maximum number of search results to be returned by a request. A number between 10 and 100. By default, a request response will return 10 results.
  ///   - nextToken: This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified.
  ///   - sinceId: Returns results with a Tweet ID greater than (that is, more recent than) the specified ID. The ID specified is exclusive and responses will not include it. If included with the same request as a `startTime` parameter, only `sinceId` will be used.
  ///   - untilId: Returns results with a Tweet ID less than (that is, older than) the specified ID. The ID specified is exclusive and responses will not include it.
  /// - Returns: A response object containing an array of Tweets matching the search query, any requested expansions, and a meta object with information for further pagination
  public func searchRecentTweets(query: String,
                                 fields: Set<Tweet.Field> = [],
                                 expansions: [Tweet.Expansions] = [],
                                 endTime: Date? = nil,
                                 startTime: Date? = nil,
                                 maxResults: Int = 10,
                                 nextToken: String? = nil,
                                 sinceId: Tweet.ID? = nil,
                                 untilId: Tweet.ID? = nil
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    switch maxResults {
    case 10...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 10, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [
      URLQueryItem(name: "max_results", value: "\(maxResults)"),
      URLQueryItem(name: "query", value: query),
    ]
    if let nextToken = nextToken { queryItems.append(URLQueryItem(name: "next_token", value: nextToken)) }
    if let sinceId = sinceId { queryItems.append(URLQueryItem(name: "since_id", value: sinceId)) }
    if let untilId = untilId { queryItems.append(URLQueryItem(name: "until_id", value: untilId)) }
    if let startTime = startTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "start_time", value: startTime)) }
    if let endTime = endTime?.ISO8601Format() { queryItems.append(URLQueryItem(name: "end_time", value: endTime)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .searchRecent,
                          queryItems: queryItems + fieldsAndExpansions,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
}
