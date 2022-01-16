import Foundation

extension Twift {
  // MARK: Mutes methods
  
  /// Returns a list of users who are muted by the specified user ID.
  ///
  /// Equivalent to `GET /2/users/:id/muting`.
  /// - Parameters:
  ///   - userId: The user ID whose muted users you would like to retrieve
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A Twitter API response object containing an array of ``User`` structs and any pinned tweets in the `includes` property
  public func getMutedUsers(for userId: User.ID,
                            fields: Set<User.Fields> = [],
                            expansions: [User.Expansions] = [],
                            paginationToken: String? = nil,
                            maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    switch maxResults {
    case 0...1000:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 1000, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    if !fields.isEmpty { queryItems.append(URLQueryItem(name: "user.fields", value: fields.map(\.rawValue).joined(separator: ","))) }
    if !expansions.isEmpty { queryItems.append(URLQueryItem(name: "expansions", value: expansions.map(\.rawValue).joined(separator: ","))) }
    
    for expansion in expansions { queryItems.append(expansion.fields) }
    
    return try await call(route: .muting(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Causes the source user to mute the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `POST /2/users/:id/muting`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the mute on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to mute.
  /// - Returns: A ``MuteResponse`` indicating the muted status.
  public func muteUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<MuteResponse> {
    let body = ["target_user_id": targetUserId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .muting(sourceUserId),
                          method: .POST,
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Causes the source user to mute the target user. The source user ID must match the currently authenticated user ID.
  ///
  /// Equivalent to `DELETE /2/users/:source_user_id/muting/:target_user_id`
  /// - Parameters:
  ///   - sourceUserId: The user ID who you would like to initiate the mute on behalf of. It must match the user ID of the currently authenticated user.
  ///   - targetUserId: The user ID of the user you would like the source user to mute.
  /// - Returns: A ``MuteResponse`` indicating the muted status.
  public func unmuteUser(sourceUserId: User.ID, targetUserId: User.ID) async throws -> TwitterAPIData<MuteResponse> {
    return try await call(route: .deleteMute(sourceUserId: sourceUserId, targetUserId: targetUserId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
}

/// A response object containing information relating to a mute status.
public struct MuteResponse: Codable {
  /// Indicates whether the id is muting the specified user as a result of this request.
  public let muting: Bool
}
