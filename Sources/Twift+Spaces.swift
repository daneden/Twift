import Foundation

extension Twift {
  // MARK: Spaces Lookup
  
  /// Returns a variety of information about a single Space specified by the requested ID.
  /// - Parameters:
  ///   - id: Unique identifier of the Space to request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the requested Space and any requested expansions
  public func getSpace(_ id: Space.ID,
                       fields: Set<Space.Field> = [],
                       expansions: [Space.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<Space, Space.Includes> {
    return try await call(route: .spaces(id),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: Space.self, fields: fields, expansions: expansions))
  }
  
  /// Returns details about multiple Spaces. Up to 100 comma-separated Spaces IDs can be looked up using this endpoint.
  /// - Parameters:
  ///   - ids: A comma separated list of Spaces (up to 100).
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the requested Space and any requested expansions
  public func getSpaces(_ ids: [Space.ID],
                       fields: Set<Space.Field> = [],
                       expansions: [Space.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[Space], Space.Includes> {
    let queryItems = [URLQueryItem(name: "ids", value: ids.joined(separator: ","))]
    return try await call(route: .spaces(),
                          method: .GET,
                          queryItems: queryItems + fieldsAndExpansions(for: Space.self, fields: fields, expansions: expansions))
  }
  
  /// Return live or scheduled Spaces matching your specified search terms. This endpoint performs a keyword search, meaning that it will return Spaces that are an exact case-insensitive match of the specified search term. The search term will match the original title of the Space.
  ///
  /// Equivalent to `GET /2/spaces/search`
  /// - Parameters:
  ///   - query: Your search term. This can be any text (including mentions and Hashtags) present in the title of the Space.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - state: Determines the type of results to return. This endpoint returns all Spaces by default.
  /// - Returns: A response object containing an array of Spaces matching the search query, any requested expansions, and a meta object with result count information.
  public func searchSpaces(query: String,
                           fields: Set<Space.Field> = [],
                           expansions: [Space.Expansions] = [],
                           state: SearchSpacesState = .all
  ) async throws -> TwitterAPIDataAndIncludes<[Space], Space.Includes> {
    let queryItems = [URLQueryItem(name: "query", value: query)]
    return try await call(route: .searchSpaces,
                          queryItems: queryItems + fieldsAndExpansions(for: Space.self, fields: fields, expansions: expansions))
  }
  
  /// Returns a list of user who purchased a ticket to the requested Space. You must authenticate the request using the access token of the creator of the requested Space.
  ///
  /// Equivalent to `GET /2/spaces/:id/buyers`
  /// - Parameters:
  ///   - spaceId: Unique identifier of the Space for which you want to request buyers.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing an array of Users who bought tickets to the Space, and any requested expansions
  public func getSpaceBuyers(_ spaceId: Space.ID,
                             fields: Set<User.Field> = [],
                             expansions: [User.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[User], User.Includes> {
    return try await call(route: .spaces(spaceId, subpath: .buyers),
                          queryItems: fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions))
  }
  
  /// Returns Tweets shared in the requested Spaces.
  ///
  /// Equivalent to `GET /2/spaces/:id/tweets`
  /// - Parameters:
  ///   - spaceId: Unique identifier of the Space containing the Tweets you'd like to access.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing an array of Tweets shared in the Space, and any requested expansions
  public func getSpaceTweets(_ spaceId: Space.ID,
                             fields: Set<Tweet.Field> = [],
                             expansions: [Tweet.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[Tweet], Tweet.Includes> {
    return try await call(route: .spaces(spaceId, subpath: .tweets),
                          queryItems: fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions))
  }
  
  /// Returns live or scheduled Spaces created by the specified user IDs. Up to 100 comma-separated IDs can be looked up using this endpoint.
  /// - Parameters:
  ///   - userIds: A list of user IDs (up to 100).
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing an array of Spaces, and any requested expansions
  public func getSpacesByCreatorIds(_ userIds: [User.ID],
                                    fields: Set<Space.Field> = [],
                                    expansions: [Space.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[Space], Space.Includes> {
    let queryItems = [URLQueryItem(name: "user_ids", value: userIds.joined(separator: ","))]
    return try await call(route: .spacesByCreatorIds,
                          queryItems: queryItems + fieldsAndExpansions(for: Space.self, fields: fields, expansions: expansions))
  }
}

public enum SearchSpacesState: String {
  /// Returns only spaces that are currently live
  case live
  
  /// Returns only spaces that are scheduled for a future date
  case scheduled
  
  /// Returns all spaces matching the query
  case all
}
