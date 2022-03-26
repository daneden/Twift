//
//  File.swift
//  
//
//  Created by Daniel Eden on 26/03/2022.
//

import Foundation

extension Twift {
  /// Allows you to get an authenticated user's 800 most recent bookmarked Tweets.
  ///
  /// Equivalent to `GET /2/users/:id/bookmarks`
  /// - Parameters:
  ///   - userId: User ID of an authenticated user to request bookmarked Tweets for.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``Tweet`` structs representing the authenticated user's bookmarked Tweets
  public func getBookmarks(for userId: User.ID? = nil,
                           fields: Set<Tweet.Field> = [],
                           expansions: [Tweet.Expansions] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .bookmarks(userId),
                          queryItems: queryItems + fieldsAndExpansions,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
}
