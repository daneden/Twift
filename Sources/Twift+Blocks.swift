import Foundation

extension Twift {
  // MARK: Blocks methods
  
  /// Returns a list of users who are blocked by the specified user ID.
  ///
  /// Equivalent to `GET /2/users/:id/blocking`.
  /// - Parameters:
  ///   - userId: The user ID whose blocked users you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getBlockedUsers(for userId: User.ID,
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
    
    return try await call(route: .blocking(userId),
                          queryItems: queryItems)
  }
  
  /// Causes the source user to block the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `POST /2/users/:id/blocking`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the block on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to block.
  /// - Returns: A ``BlockResponse`` indicating the blocked status.
  public func blockUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<BlockResponse> {
    let body = ["target_user_id": targetUserId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .blocking(sourceUserId),
                          method: .POST,
                          body: serializedBody)
  }
  
  /// Causes the source user to block the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `DELETE /2/users/:source_user_id/blocking/:target_user_id`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the block on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to block.
  /// - Returns: A ``BlockResponse`` indicating the blocked status.
  public func unblockUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<BlockResponse> {
    return try await call(route: .deleteBlock(sourceUserId: sourceUserId, targetUserId: targetUserId),
                          method: .DELETE)
  }
}


/// A response object containing information relating to a block status.
public struct BlockResponse: Codable {
  /// Indicates whether the source id is blocking the target id as a result of this request.
  public let blocking: Bool
}
