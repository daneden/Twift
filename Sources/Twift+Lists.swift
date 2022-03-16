import Foundation

extension Twift {
  // MARK: List Tweets
  
  /// Returns a list of Tweets from the specified List.
  ///
  /// Equivalent to `GET /2/lists/:list_id/tweets`
  /// - Parameters:
  ///   - listId: The ID of the List whose Tweets you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Tweets, included expansions, and meta data for pagination
  public func getListTweets(_ listId: TwiftList.ID,
                            fields: Set<Tweet.Field>,
                            expansions: [Tweet.Expansions],
                            paginationToken: String? = nil,
                            maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .listTweets(listId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  // MARK: List Lookup
  
  /// Returns the details of a specified List.
  ///
  /// Equivalent to `GET /2/lists/:list_id`
  /// - Parameters:
  ///   - listId: The ID of the List to lookup.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the List and expanded objects
  public func getList(_ listId: TwiftList.ID,
                      fields: Set<TwiftList.Field>,
                      expansions: [TwiftList.Expansions]
  ) async throws -> TwitterAPIDataAndIncludes<TwiftList, TwiftList.Includes> {
    return try await call(route: .list(listId),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: TwiftList.self, fields: fields, expansions: expansions),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns all Lists owned by the specified user.
  ///
  /// Equivalent to `GET /2/user/:user_id/owned_lists`
  /// - Parameters:
  ///   - userId: The user ID whose owned Lists you would like to retrieve. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Lists owned by the user id, any requested expansions, and a meta object with pagination tokens
  public func getUserOwnedLists(_ userId: User.ID? = nil,
                                fields: Set<TwiftList.Field>,
                                expansions: [TwiftList.Expansions],
                                paginationToken: String?,
                                maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[TwiftList], TwiftList.Includes, Meta> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: TwiftList.self, fields: fields, expansions: expansions)
    
    return try await call(route: .userOwnedLists(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  // MARK: Manage Lists
  
  /// Enables the authenticated user to delete a List that they own.
  /// - Parameter listId: The ID of the List to be deleted.
  /// - Returns: A response object containing the result of the delete request
  public func deleteList(_ listId: TwiftList.ID) async throws -> TwitterAPIData<DeleteResponse> {
    return try await call(route: .list(listId), method: .DELETE, expectedReturnType: TwitterAPIData.self)
  }
}

extension Twift {
  // MARK: List Membership
  
  /// Returns all Lists a specified user is a member of.
  ///
  /// Equivalent to `GET /2/user/:user_id/list_memberships`
  /// - Parameters:
  ///   - userId: The user ID whose List memberships you would like to retrieve. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Lists the user is a member of, any expanded objects, and a meta object with pagination tokens.
  public func getListMemberships(for userId: User.ID? = nil,
                                 fields: Set<TwiftList.Field>,
                                 expansions: [TwiftList.Expansions],
                                 paginationToken: String?,
                                 maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[TwiftList], TwiftList.Includes, Meta> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: TwiftList.self, fields: fields, expansions: expansions)
    
    return try await call(route: .userListMemberships(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Returns a list of users who are members of the specified List.
  ///
  /// Equivalent to `GET /2/lists/:list_id/members`
  /// - Parameters:
  ///   - listId: The ID of the List whose members you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Users who are members of the target list, any requested expansions, and a meta object with pagination tokens.
  public func getListMembers(for listId: TwiftList.ID,
                             fields: Set<User.Field>,
                             expansions: [User.Expansions],
                             paginationToken: String?,
                             maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .listMembers(listId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Enables the authenticated user to remove a member from a List they own.
  /// - Parameters:
  ///   - userId: The ID of the user you wish to remove as a member of the List.
  ///   - listId: The ID of the List you are removing a member from.
  /// - Returns: A response object containing the result of this delete request
  public func deleteListMember(_ userId: User.ID, from listId: TwiftList.ID) async throws -> TwitterAPIData<DeleteResponse> {
    return try await call(route: .removeListMember(listId, userId: userId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Enables the authenticated user to add a member to a List they own.
  /// - Parameters:
  ///   - userId: The ID of the user you wish to add as a member of the List.
  ///   - listId: The ID of the List you are adding a member to.
  /// - Returns: A response object containing the result of this membership request
  public func addListMember(_ userId: User.ID, to listId: TwiftList.ID) async throws -> TwitterAPIData<ListMembershipResponse> {
    let body = ["user_id": userId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .listMembers(listId),
                          method: .POST,
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
}

/// A response object containing information relating to a list membership request.
public struct ListMembershipResponse: Codable {
  /// Indicates whether the user is a member of the specified List as a result of the request.
  public let isMember: Bool
}

extension Twift {
  // MARK: List Follows
  
  /// Enables the authenticated user to unfollow a List.
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to unfollow.
  ///   - userId: The user ID who you are unfollowing a List on behalf of. It must match your own user ID or that of an authenticating user. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  /// - Returns: A response object containing the result of the unfollow request
  public func unfollowList(_ listId: TwiftList.ID, userId: User.ID? = nil) async throws -> TwitterAPIData<FollowResponse> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    return try await call(route: .userFollowingLists(userId, listId: listId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Enables the authenticated user to follow a List.
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to follow.
  ///   - userId: The user ID who you are following a List on behalf of. It must match your own user ID or that of an authenticating user. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  /// - Returns: A response object containing the result of the follow request
  public func followList(_ listId: TwiftList.ID, userId: User.ID? = nil) async throws -> TwitterAPIData<FollowResponse> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    return try await call(route: .userFollowingLists(userId),
                          method: .POST,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Returns a list of users who are followers of the specified List.
  /// - Parameters:
  ///   - listId: The ID of the List whose followers you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Users following the list, any requested expansions, and a meta object with pagination information
  public func getListFollowers(_ listId: TwiftList.ID,
                               fields: Set<User.Field> = [],
                               expansions: [User.Expansions] = [],
                               paginationToken: String? = nil,
                               maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[User], User.Includes, Meta> {
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: User.self, fields: fields, expansions: expansions)
    
    return try await call(route: .listFollowers(listId),
                          method: .GET,
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  /// Returns all Lists a specified user follows.
  /// - Parameters:
  ///   - userId: The user ID whose followed Lists you would like to retrieve. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of lists followed by the user, any requested expansions, and a meta object with pagination information
  public func getFollowedLists(_ userId: User.ID? = nil,
                               fields: Set<TwiftList.Field> = [],
                               expansions: [TwiftList.Expansions],
                               paginationToken: String? = nil,
                               maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[TwiftList], TwiftList.Includes, Meta> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    switch maxResults {
    case 1...100:
      break
    default:
      throw TwiftError.RangeOutOfBoundsError(min: 1, max: 100, fieldName: "maxResults", actual: maxResults)
    }
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: TwiftList.self, fields: fields, expansions: expansions)
    
    
    return try await call(route: .userFollowingLists(userId),
                          method: .GET,
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
}

extension Twift {
  /// Enables the authenticated user to pin a List.
  ///
  /// Equivalent to `POST /2/users/:user_id/pinned_lists`
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to pin.
  ///   - userId: The user ID who you are pinning a List on behalf of. It must match your own user ID or that of an authenticating user. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  /// - Returns: A response object containing the result of this pin list request
  public func pinList(_ listId: TwiftList.ID, userId: User.ID? = nil) async throws -> TwitterAPIData<PinnedResponse> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    let body = ["list_id": listId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .userPinnedLists(userId),
                          method: .POST,
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Enables the authenticated user to unpin a List.
  ///
  /// Equivalent to `DELETE /2/users/:user_id/pinned_lists/:list_id`
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to unpin.
  ///   - userId: The user ID who you are unpinning a List on behalf of. It must match your own user ID or that of an authenticating user. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  /// - Returns: A response object containing the result of this unpin list request
  public func unpinList(_ listId: TwiftList.ID, userId: User.ID? = nil) async throws -> TwitterAPIData<PinnedResponse> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    return try await call(route: .userPinnedLists(userId, listId: listId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
  }
  
  /// Returns all Lists a specified user has pinned.
  /// - Parameters:
  ///   - userId: The user ID whose pinned Lists you would like to retrieve. When set to `nil`, this method will try to use the currently-authenticated user's ID.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing an array of lists pinned by the user, any requested expansions, and a meta object with pagination information
  public func getPinnedLists(_ userId: User.ID? = nil,
                               fields: Set<TwiftList.Field> = [],
                               expansions: [TwiftList.Expansions]
  ) async throws -> TwitterAPIDataAndIncludes<[TwiftList], TwiftList.Includes> {
    guard let userId = userId ?? authenticatedUserId else { throw TwiftError.MissingUserID }
    
    return try await call(route: .userPinnedLists(userId),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: TwiftList.self, fields: fields, expansions: expansions),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
}

/// A response object containing information relating to a pinned list request.
public struct PinnedResponse: Codable {
  /// Indicates whether the user pinned the specified List as a result of the request.
  public let pinned: Bool
}
