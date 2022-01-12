import Foundation

public enum UserID {
  case id(_: String)
  case screenName(_: String)
}

extension Twift {
  /// Returns a variety of information about a single user specified by the requested ID or screen name.
  /// - Parameters:
  ///   - wrappedUserID: The ID or screen name of the user to lookup.
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `User`.
  /// - Returns: A `User` struct with the requested fields and expansions
  public func getUser(by wrappedUserID: UserID,
                      userFields: [User.Fields] = [],
                      tweetFields: [Tweet.Fields] = []
  ) async throws -> User {
    var userId: String = ""
    if case .id(let unwrappedId) = wrappedUserID {
      guard unwrappedId.isIntString else {
        throw TwiftError.MalformedUserIDError(unwrappedId)
      }
      userId = unwrappedId
    } else if case .screenName(let unwrappedScreenName) = wrappedUserID {
      // Looking up users by their screen name requires either OAuth 1.0 user
      // authentication or OAuth 2.0 Bearer Token
      if userCredentials == nil {
        throw TwiftError.MissingCredentialsError
      }
      
      let url = URL(string: "https://api.twitter.com/2/users/by/username/\(unwrappedScreenName)")!
      var userIdRequest = URLRequest(url: url)
      
      try signURLRequest(method: .GET, request: &userIdRequest)
      
      let (data, _) = try await URLSession.shared.data(for: userIdRequest)
      let decodedUser = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
      if let error = decodedUser.error { throw error }
      guard let user = decodedUser.data else { throw TwiftError.UserNotFoundError(wrappedUserID) }
      
      userId = user.id
    }
    
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    
    let url = getURL(for: .users([userId]), queryItems: queryItems)
    var userRequest = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &userRequest)

    let (data, _) = try await URLSession.shared.data(for: userRequest)
    let decodedUser = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
    if let error = decodedUser.error { throw error }
    guard var user = decodedUser.data else { throw TwiftError.UserNotFoundError(wrappedUserID) }
    user.includes = decodedUser.includes
    
    return user
  }
  
  /// Returns a variety of information about a single user specified by the requested ID or screen name.
  /// - Parameters:
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `User`.
  /// - Returns: A `User` struct with the requested fields and expansions
  public func getMe(userFields: [User.Fields] = [], tweetFields: [Tweet.Fields] = []) async throws -> User {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)
    
    let url = getURL(for: .me, queryItems: queryItems)
    var userRequest = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &userRequest)
    
    let (data, _) = try await URLSession.shared.data(for: userRequest)
    let decodedUser = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
    if let error = decodedUser.error { throw error }
    guard var user = decodedUser.data else { throw TwiftError.UnknownError }
    
    if let includes = decodedUser.includes { user.includes = includes }
    
    return user
  }
  
  func getUsers(withIds userIds: [User.ID], userFields: [User.Fields] = [], tweetFields: [Tweet.Fields] = []) async throws -> ManyUsers {
    let queryItems = buildQueryItems(userFields: userFields, tweetFields: tweetFields)

    let url = getURL(for: .users(userIds), queryItems: queryItems)
    var request = URLRequest(url: url)
    try signURLRequest(method: .GET, request: &request)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let decodedUser = try decoder.decode(TwitterAPIResponse<ManyUsers>.self, from: data)
    if let error = decodedUser.error { throw error }
    guard var users = decodedUser.data else { throw TwiftError.UnknownError }
    
    if let includes = decodedUser.includes { users.includes = includes }
    
    return users
  }
}
