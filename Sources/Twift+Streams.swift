import Foundation

public extension Twift {
  /// Streams about 1% of all Tweets in real-time.
  ///
  /// Equivalent to `GET /2/tweets/sample/stream`
  /// - Parameters:
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - backfillMinutes: By passing this parameter, you can request up to five (5) minutes worth of streaming data that you might have missed during a disconnection to be delivered to you upon reconnection. The backfilled Tweets will automatically flow through the reconnected stream, with older Tweets generally being delivered before any newly matching Tweets. You must include a whole number between 1 and 5 as the value to this parameter.
  /// This feature will deliver duplicate Tweets, meaning that if you were disconnected for 90 seconds, and you requested two minutes of backfill, you will receive 30 seconds worth of duplicate Tweets. Due to this, you should make sure your system is tolerant of duplicate data.
  /// This feature is currently only available to the Academic Research product track.
  /// - Returns: An `AsyncSequence` of `TwitterAPIDataAndIncludes<Tweet, Tweet.Includes>` objects.
  func volumeStream(fields: Set<Tweet.Field> = [],
                    expansions: [Tweet.Expansions] = [],
                    backfillMinutes: Int? = nil
  ) async throws -> AsyncThrowingCompactMapSequence<AsyncLineSequence<URLSession.AsyncBytes>, TwitterAPIDataAndIncludes<Tweet, Tweet.Includes>> {
    var queryItems = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    if let backfillMinutes = backfillMinutes {
      switch backfillMinutes {
      case 0...5:
        break
      default:
        throw TwiftError.RangeOutOfBoundsError(min: 0, max: 5, fieldName: "backfillMinutes", actual: backfillMinutes)
      }
      
      queryItems.append(URLQueryItem(name: "backfill_minutes", value: "\(backfillMinutes)"))
    }
    
    let url = getURL(for: .volumeStream, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &request)
    
    let (bytes, response) = try await URLSession.shared.bytes(for: request)
    
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
            throw URLError.init(.resourceUnavailable)
          }
    
    return bytes.lines
      .compactMap {
        try? self.decodeOrThrow(decodingType: TwitterAPIDataAndIncludes.self, data: Data($0.utf8))
      }
      
  }
}
