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
  public func getListTweets(_ listId: List.ID,
                            fields: Set<Tweet.Field> = [],
                            expansions: [Tweet.Expansions] = [],
                            paginationToken: String? = nil,
                            maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[Tweet], Tweet.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    return try await call(route: .listTweets(listId),
                          queryItems: queryItems)
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
  public func getList(_ listId: List.ID,
                      fields: Set<List.Field> = [],
                      expansions: [List.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<List, List.Includes> {
    return try await call(route: .list(listId),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions))
  }
  
  /// Returns all Lists owned by the specified user.
  ///
  /// Equivalent to `GET /2/user/:user_id/owned_lists`
  /// - Parameters:
  ///   - userId: The user ID whose owned Lists you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Lists owned by the user id, any requested expansions, and a meta object with pagination tokens
  public func getUserOwnedLists(_ userId: User.ID,
                                fields: Set<List.Field> = [],
                                expansions: [List.Expansions] = [],
                                paginationToken: String? = nil,
                                maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[List], List.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions)
    
    return try await call(route: .userOwnedLists(userId),
                          queryItems: queryItems)
  }
  
  // MARK: Manage Lists
  
  /// Enables the authenticated user to delete a List that they own.
  /// - Parameter listId: The ID of the List to be deleted.
  /// - Returns: A response object containing the result of the delete request
  public func deleteList(_ listId: List.ID) async throws -> TwitterAPIData<DeleteResponse> {
    return try await call(route: .list(listId), method: .DELETE)
  }
  
  /// Enables the authenticated user to create a new List.
  ///
  /// Equivalent to `POST /2/lists`
  /// - Parameters:
  ///  - name: List name (required)
  ///  - description: Description for the list (optional)
  ///  - private: Determines whether the list should be private
  /// - Returns: A response object containing the name and the ID of the list.
  public func createList(name: String, description: String? = nil, isPrivate: Bool = false) async throws -> TwitterAPIData<CreatedListResponse> {
    var body: [String : Any] = [
      "name": name,
      "private": isPrivate
    ]
    
    if let description = description {
      body["description"] = description
    }
    
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .createList,
                          method: .POST,
                          body: serializedBody)
  }
  
  /// Enables the authenticated user to create a new List.
  ///
  /// Equivalent to `PUT /2/lists`
  /// - Parameters:
  ///  - id: The ID of the list to be updated
  ///  - name: Updates the name of the list
  ///  - description: Updates the description of the list
  ///  - private: Determines whether the list should be private
  /// - Returns: A response object indicating whether the target list was updated.
  public func updateList(id: List.ID, name: String? = nil, description: String? = nil, isPrivate: Bool? = nil) async throws -> TwitterAPIData<UpdatedListResponse> {
    var body: [String : Any] = [:]
    
    if let name = name { body["name"] = name }
    if let description = description { body["description"] = description }
    if let isPrivate = isPrivate { body["private"] = isPrivate }
    
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .list(id),
                          method: .PUT,
                          body: serializedBody)
  }
  
}

extension Twift {
  // MARK: List Membership
  
  /// Returns all Lists a specified user is a member of.
  ///
  /// Equivalent to `GET /2/user/:user_id/list_memberships`
  /// - Parameters:
  ///   - userId: The user ID whose List memberships you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Lists the user is a member of, any expanded objects, and a meta object with pagination tokens.
  public func getListMemberships(for userId: User.ID,
                                 fields: Set<List.Field> = [],
                                 expansions: [List.Expansions] = [],
                                 paginationToken: String? = nil,
                                 maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[List], List.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions)
    
    return try await call(route: .userListMemberships(userId),
                          queryItems: queryItems)
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
  public func getListMembers(for listId: List.ID,
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
    
    return try await call(route: .listMembers(listId),
                          queryItems: queryItems)
  }
  
  /// Enables the authenticated user to remove a member from a List they own.
  /// - Parameters:
  ///   - userId: The ID of the user you wish to remove as a member of the List.
  ///   - listId: The ID of the List you are removing a member from.
  /// - Returns: A response object containing the result of this delete request
  public func deleteListMember(_ userId: User.ID, from listId: List.ID) async throws -> TwitterAPIData<ListMembershipResponse> {
    return try await call(route: .removeListMember(listId, userId: userId),
                          method: .DELETE)
  }
  
  /// Enables the authenticated user to add a member to a List they own.
  /// - Parameters:
  ///   - userId: The ID of the user you wish to add as a member of the List.
  ///   - listId: The ID of the List you are adding a member to.
  /// - Returns: A response object containing the result of this membership request
  public func addListMember(_ userId: User.ID, to listId: List.ID) async throws -> TwitterAPIData<ListMembershipResponse> {
    let body = ["user_id": userId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .listMembers(listId),
                          method: .POST,
                          body: serializedBody)
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
  ///   - userId: The user ID who you are unfollowing a List on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing the result of the unfollow request
  public func unfollowList(_ listId: List.ID, userId: User.ID) async throws -> TwitterAPIData<FollowResponse> {
    return try await call(route: .userFollowingLists(userId, listId: listId),
                          method: .DELETE)
  }
  
  /// Enables the authenticated user to follow a List.
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to follow.
  ///   - userId: The user ID who you are following a List on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing the result of the follow request
  public func followList(_ listId: List.ID, userId: User.ID) async throws -> TwitterAPIData<FollowResponse> {
    let body = ["list_id": listId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    
    return try await call(route: .userFollowingLists(userId),
                          method: .POST,
                          body: serializedBody)
  }
  
  /// Returns a list of users who are followers of the specified List.
  /// - Parameters:
  ///   - listId: The ID of the List whose followers you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Users following the list, any requested expansions, and a meta object with pagination information
  public func getListFollowers(_ listId: List.ID,
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
    
    return try await call(route: .listFollowers(listId),
                          method: .GET,
                          queryItems: queryItems)
  }
  
  /// Returns all Lists a specified user follows.
  /// - Parameters:
  ///   - userId: The user ID whose followed Lists you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of lists followed by the user, any requested expansions, and a meta object with pagination information
  public func getFollowedLists(_ userId: User.ID,
                               fields: Set<List.Field> = [],
                               expansions: [List.Expansions] = [],
                               paginationToken: String? = nil,
                               maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[List], List.Includes, Meta> {
    var queryItems = [URLQueryItem(name: "max_results", value: "\(maxResults)")]
    
    if let paginationToken = paginationToken {
      queryItems.append(URLQueryItem(name: "pagination_token", value: paginationToken))
    }
    
    queryItems += fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions)
    
    
    return try await call(route: .userFollowingLists(userId),
                          method: .GET,
                          queryItems: queryItems)
  }
}

extension Twift {
  /// Enables the authenticated user to pin a List.
  ///
  /// Equivalent to `POST /2/users/:user_id/pinned_lists`
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to pin.
  ///   - userId: The user ID who you are pinning a List on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing the result of this pin list request
  public func pinList(_ listId: List.ID, userId: User.ID) async throws -> TwitterAPIData<PinnedResponse> {
    let body = ["list_id": listId]
    let serializedBody = try JSONSerialization.data(withJSONObject: body)
    return try await call(route: .userPinnedLists(userId),
                          method: .POST,
                          body: serializedBody)
  }
  
  /// Enables the authenticated user to unpin a List.
  ///
  /// Equivalent to `DELETE /2/users/:user_id/pinned_lists/:list_id`
  /// - Parameters:
  ///   - listId: The ID of the List that you would like the user id to unpin.
  ///   - userId: The user ID who you are unpinning a List on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing the result of this unpin list request
  public func unpinList(_ listId: List.ID, userId: User.ID) async throws -> TwitterAPIData<PinnedResponse> {
    return try await call(route: .userPinnedLists(userId, listId: listId),
                          method: .DELETE)
  }
  
  /// Returns all Lists a specified user has pinned.
  /// - Parameters:
  ///   - userId: The user ID whose pinned Lists you would like to retrieve.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing an array of lists pinned by the user, any requested expansions, and a meta object with pagination information
  public func getPinnedLists(_ userId: User.ID,
                             fields: Set<List.Field> = [],
                             expansions: [List.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<[List], List.Includes> {
    return try await call(route: .userPinnedLists(userId),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions))
  }
}

/// A response object containing information relating to a pinned list request.
public struct PinnedResponse: Codable {
  /// Indicates whether the user pinned the specified List as a result of the request.
  public let pinned: Bool
}

/// A response object containing information relating to newly-created lists
public struct CreatedListResponse: Codable {
  /// The ID for the newly-created List
  public let id: List.ID
  /// The name for the newly-created List
  public let name: String
}

/// A response object containing information relating to updated lists
public struct UpdatedListResponse: Codable {
  /// Indicates whether the List specified in the request has been updated.
  public let updated: Bool
}
