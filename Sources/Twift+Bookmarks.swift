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
  public func getBookmarks(for userId: User.ID,
                           fields: Set<Tweet.Field> = [],
                           expansions: [Tweet.Expansions] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 10
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    if let paginationToken = paginationToken { queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken)) }
    
    let fieldsAndExpansions = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .bookmarks(userId),
                          queryItems: queryItems + fieldsAndExpansions)
  }
  
  /// Causes the user ID of an authenticated user identified in the path parameter to Bookmark the target Tweet
  ///
  /// Equivalent to `POST /2/users/:id/bookmarks`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to Bookmark.
  ///   - userId: The user ID who you are liking a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing a ``BookmarkResponse``
  public func addBookmark(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<BookmarkResponse> {
    let body = ["tweet_id": tweetId]
    let encodedBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    return try await call(route: .bookmarks(userId),
                          method: .POST,
                          body: encodedBody)
  }
  
  /// Allows a user or authenticated user ID to remove a Bookmark of a Tweet.
  ///
  /// Equivalent to `DELETE /2/users/:user_id/bookmarks/:tweet_id`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to unlike.
  ///   - userId: The user ID who you are removing Like of a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing a ``BookmarkResponse``
  public func deleteBookmark(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<BookmarkResponse> {
    return try await call(route: .deleteBookmark(userId: userId, tweetId: tweetId),
                          method: .DELETE)
  }
}

/// A response object containing information relating to Bookmark-related API requests
public struct BookmarkResponse: Codable {
  /// Indicates whether the user bookmarked the specified Tweet as a result of this request.
  public let bookmarked: Bool
}
