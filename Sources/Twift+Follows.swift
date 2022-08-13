//
//  File.swift
//  
//
//  Created by Daniel Eden on 13/01/2022.
//

import Foundation

extension Twift {
  // MARK: Follows methods
  
  /// Returns a list of users the specified user ID is following.
  ///
  /// Equivalent to `GET /2/users/:id/following`.
  /// - Parameters:
  ///   - userId: The user ID whose following you would like to retreive.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getFollowing(_ userId: User.ID,
                           fields: Set<User.Field> = [],
                           expansions: [User.Expansions] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .following(userId),
                          queryItems: queryItems)
  }
  
  /// Returns a list of users who are followers of the specified user ID.
  ///
  /// Equivalent to `GET /2/users/:id/followers`.
  /// - Parameters:
  ///   - userId: The user ID whose followers you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getFollowers(_ userId: User.ID,
                           fields: Set<User.Field> = [],
                           expansions: [User.Expansions] = [],
                           paginationToken: String? = nil,
                           maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .followers(userId),
                          queryItems: queryItems)
  }
  
  /// Allows a user ID to follow another user.
  ///
  /// Equivalent to `POST /2/user/:user_id/following`.
  ///
  /// If the target user does not have public Tweets, this endpoint will send a follow request.
  ///
  /// The request succeeds with no action when the authenticated user sends a request to a user they're already following, or if they're sending a follower request to a user that does not have public Tweets.
  /// - Parameters:
  ///   - sourceUserId: The authenticated user ID who you would like to initiate the follow on behalf of.
  ///   - targetUserId: The user ID of the user that you would like the `sourceUserId` to follow.
  /// - Returns: A ``FollowResponse`` indicating whether the source user is now following the target user, and whether the follow request is pending
  public func followUser(
    sourceUserId: User.ID,
    targetUserId: User.ID
  ) async throws -> TwitterAPIData<FollowResponse> {
    let body = ["target_user_id": targetUserId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .following(sourceUserId),
                          method: .POST,
                          body: serializedBody)
  }
  
  /// Allows a user ID to unfollow another user.
  ///
  /// Equivalent to `DELETE /2/user/:source_user_id/following/:target_user_id`.
  ///
  /// The request succeeds with no action when the authenticated user sends a request to a user they're not following or have already unfollowed.
  /// - Parameters:
  ///   - sourceUserId: The authenticated user ID who you would like to initiate the unfollow on behalf of.
  ///   - targetUserId: The user ID of the user that you would like the `sourceUserId` to unfollow.
  /// - Returns: A ``FollowResponse`` indicating whether the source user is now following the target user
  public func unfollowUser(sourceUserId: User.ID,
                           targetUserId: User.ID
  ) async throws -> TwitterAPIData<FollowResponse> {
    return try await call(route: .deleteFollow(sourceUserId: sourceUserId, targetUserId: targetUserId),
                          method: .DELETE)
  }
}

/// A response object containing information relating to a follow status.
public struct FollowResponse: Codable {
  /// Indicates whether the id is following the specified object (User or List) as a result of this request. This value is false if the target is a user without public Tweets, as they will have to approve the follower request.
  public let following: Bool
  
  /// Indicates whether the target user will need to approve the follow request. Note that the authenticated user will follow the target user only when they approve the incoming follower request.
  public let pendingFollow: Bool?
}
