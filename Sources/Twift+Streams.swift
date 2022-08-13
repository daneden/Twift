import Foundation

extension Twift {
  // MARK: Streams
  
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
  public func volumeStream(fields: Set<Tweet.Field> = [],
                           expansions: [Tweet.Expansions] = [],
                           backfillMinutes: Int? = nil
  ) async throws -> AsyncThrowingCompactMapSequence<AsyncLineSequence<URLSession.AsyncBytes>, TwitterAPIDataAndIncludes<Tweet, Tweet.Includes>> {
    guard case .appOnly(_) = authenticationType else { throw TwiftError.WrongAuthenticationType(needs: .appOnly) }
    
    var queryItems = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    if let backfillMinutes = backfillMinutes {
      queryItems.append(URLQueryItem(name: "backfill_minutes", value: "\(backfillMinutes)"))
    }
    
    let url = getURL(for: .volumeStream, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    signURLRequest(method: .GET, request: &request)
    
    let (bytes, response) = try await URLSession.shared.bytes(for: request)
    
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
            throw URLError.init(.resourceUnavailable)
          }
    
    return bytes.lines
      .compactMap {
        try? await self.decodeOrThrow(decodingType: TwitterAPIDataAndIncludes.self, data: Data($0.utf8))
      }
  }
  
  /// Streams Tweets in real-time based on a specific set of filter rules.
  ///
  /// Equivalent to `GET /2/tweets/search/stream`
  /// - Parameters:
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - backfillMinutes: By passing this parameter, you can request up to five (5) minutes worth of streaming data that you might have missed during a disconnection to be delivered to you upon reconnection. The backfilled Tweets will automatically flow through the reconnected stream, with older Tweets generally being delivered before any newly matching Tweets. You must include a whole number between 1 and 5 as the value to this parameter.
  /// This feature will deliver duplicate Tweets, meaning that if you were disconnected for 90 seconds, and you requested two minutes of backfill, you will receive 30 seconds worth of duplicate Tweets. Due to this, you should make sure your system is tolerant of duplicate data.
  /// This feature is currently only available to the Academic Research product track.
  /// - Returns: An `AsyncSequence` of `TwitterAPIDataAndIncludes<Tweet, Tweet.Includes>` objects.
  public func filteredStream(fields: Set<Tweet.Field> = [],
                             expansions: [Tweet.Expansions] = [],
                             backfillMinutes: Int? = nil
  ) async throws -> AsyncThrowingCompactMapSequence<AsyncLineSequence<URLSession.AsyncBytes>, TwitterAPIDataAndIncludes<Tweet, Tweet.Includes>> {
    guard case .appOnly(_) = authenticationType else { throw TwiftError.WrongAuthenticationType(needs: .appOnly) }
    
    var queryItems = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    if let backfillMinutes = backfillMinutes {
      queryItems.append(URLQueryItem(name: "backfill_minutes", value: "\(backfillMinutes)"))
    }
    
    let url = getURL(for: .filteredStream, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    signURLRequest(method: .GET, request: &request)
    
    let (bytes, response) = try await URLSession.shared.bytes(for: request)
    
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
            throw URLError.init(.resourceUnavailable)
          }
    
    return bytes.lines
      .compactMap {
        try? await self.decodeOrThrow(decodingType: TwitterAPIDataAndIncludes.self, data: Data($0.utf8))
      }
  }
}

extension Twift {
  // MARK: Stream Rules
  
  /// Return a list of rules currently active on the streaming endpoint, either as a list or individually.
  ///
  /// Equivalent to `get /2/tweets/search/stream/rules`
  /// - Parameter ids: A list of rule IDs to return. If omitted, all rules are returned.
  /// - Returns: A response object containing an array of fetched stream rules.
  public func getFilteredStreamRules(ids: [FilteredStreamRule.ID]? = nil)
  async throws -> TwitterAPIDataAndMeta<[FilteredStreamRule], FilteredStreamRuleMeta> {
    var queryItems: [URLQueryItem] = []
    if let ids = ids, !ids.isEmpty {
      queryItems.append(URLQueryItem(name: "ids", value: ids.joined(separator: ",")))
    }
    
    return try await call(route: .filteredStreamRules,
                          queryItems: queryItems)
  }
  
  /// Add or delete rules to your stream.
  ///
  /// Equivalent to `POST /2/tweets/search/stream/rules`
  /// - Parameters:
  ///   - add: An array of rule objects to add to the filtered stream
  ///   - delete: An array of rule IDs to delete from the filtered stream
  ///   - dryRun: Set to true to test a the syntax of your rule without submitting it. This is useful if you want to check the syntax of a rule before removing one or more of your existing rules.
  /// - Returns: A response object containing an optional array of rules created by the request and a meta object with details of any rules created/deleted by the request
  public func modifyFilteredStreamRules(add: [MutableFilteredStreamRule] = [],
                                        delete: [FilteredStreamRule.ID] = [],
                                        dryRun: Bool = false
  ) async throws -> TwitterAPIDataAndMeta<[FilteredStreamRule], FilteredStreamRuleMeta> {
    var queryItems: [URLQueryItem] = []
    
    if dryRun { queryItems.append(URLQueryItem(name: "dry_run", value: "true")) }
    
    let modifier = FilteredStreamRuleModifier(add: add, delete: delete)
    let serializedBody = try self.encoder.encode(modifier)
    
    return try await call(route: .filteredStreamRules,
                          method: .POST,
                          body: serializedBody)
  }
}

internal struct FilteredStreamRuleModifier: Codable {
  var add: [MutableFilteredStreamRule] = []
  var delete: [FilteredStreamRule.ID] = []
}
