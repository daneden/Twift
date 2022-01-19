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
                         fields: Set<Tweet.Fields>,
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
  public func getList(_ listId: List.ID,
                      fields: Set<List.Fields>,
                      expansions: [List.Expansions]
  ) async throws -> TwitterAPIDataAndIncludes<List, List.Includes> {
    return try await call(route: .list(listId),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
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
                                fields: Set<List.Fields>,
                                expansions: [List.Expansions],
                                paginationToken: String?,
                                maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[List], List.Includes, Meta> {
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
    
    queryItems += fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions)
    
    return try await call(route: .userOwnedLists(userId),
                          queryItems: queryItems,
                          expectedReturnType: TwitterAPIDataIncludesAndMeta.self)
  }
  
  // MARK: Manage Lists
  
  /// Enables the authenticated user to delete a List that they own.
  /// - Parameter listId: The ID of the List to be deleted.
  /// - Returns: A response object containing the result of the delete request
  public func deleteList(_ listId: List.ID) async throws -> TwitterAPIData<DeleteResponse> {
    return try await call(route: .list(listId), method: .DELETE, expectedReturnType: TwitterAPIData.self)
  }
}

extension Twift {
  // MARK: List Membership
  
  /// Returns all Lists a specified user is a member of.
  ///
  /// Equivalent to `GET /2/user/:user_id/list_memberships`
  /// - Parameters:
  ///   - userId: The user ID whose List memberships you would like to retrieve
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  ///   - paginationToken: When iterating over pages of results, you can pass in the `nextToken` from the previously-returned value to get the next page of results
  ///   - maxResults: The maximum number of results to fetch.
  /// - Returns: A response object containing an array of Lists the user is a member of, any expanded objects, and a meta object with pagination tokens.
  public func getListMemberships(for userId: User.ID,
                                 fields: Set<List.Fields>,
                                 expansions: [List.Expansions],
                                 paginationToken: String?,
                                 maxResults: Int = 100
  ) async throws -> TwitterAPIDataIncludesAndMeta<[List], List.Includes, Meta> {
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
    
    queryItems += fieldsAndExpansions(for: List.self, fields: fields, expansions: expansions)
    
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
  public func getListMembers(for listId: List.ID,
                             fields: Set<User.Fields>,
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
  public func deleteListMember(_ userId: User.ID, from listId: List.ID) async throws -> TwitterAPIData<DeleteResponse> {
    return try await call(route: .removeListMember(listId, userId: userId),
                          method: .DELETE,
                          expectedReturnType: TwitterAPIData.self)
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
                          body: serializedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
}

public struct ListMembershipResponse: Codable {
  public let isMember: Bool
}

extension Twift {
  // MARK: List Follows
}
