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
      
      if let userCredentials = userCredentials,
         let clientCredentials = clientCredentials {
        userIdRequest.oAuthSign(method: "GET", consumerCredentials: clientCredentials.helperTuple(), userCredentials: userCredentials.helperTuple())
      } else if let bearerToken = bearerToken {
        userIdRequest.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
      }
      
      let (data, _) = try await URLSession.shared.data(for: userIdRequest)
      
      let decoded = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
      
      if let error = decoded.error {
        throw error
      }
      
      guard let user = decoded.data else {
        throw TwiftError.UserNotFoundError(wrappedUserID)
      }
      
      userId = user.id
    }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.twitter.com"
    components.path = "/2/users/\(userId)"
    components.queryItems = [
      URLQueryItem(name: "user.fields", value: userFields.map(\.rawValue).joined(separator: ",")),
      URLQueryItem(name: "tweet.fields", value: tweetFields.map(\.rawValue).joined(separator: ",")),
    ]
    
    if !tweetFields.isEmpty {
      components.queryItems?.append(URLQueryItem(name: "expansions", value: User.Expansions.pinned_tweet_id.rawValue))
    }
    
    let url = components.url!
    var userRequest = URLRequest(url: url)
    
    if let clientCredentials = clientCredentials {
      userRequest.oAuthSign(method: "GET", consumerCredentials: clientCredentials.helperTuple(), userCredentials: userCredentials?.helperTuple())
    } else if let bearerToken = bearerToken {
      userRequest.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    } else {
      throw TwiftError.MissingCredentialsError
    }

    let (data, _) = try await URLSession.shared.data(for: userRequest)
    
    let decoding = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
    
    if let error = decoding.error {
      throw error
    }
    
    guard var user = decoding.data else {
      throw TwiftError.UserNotFoundError(wrappedUserID)
    }
    
    if let includes = decoding.includes {
      user.includes = includes
    }
    
    return user
  }
  
  /// Returns a variety of information about a single user specified by the requested ID or screen name.
  /// - Parameters:
  ///   - userFields: This fields parameter enables you to select which specific user fields will deliver with each returned users objects. These specified user fields will display directly in the returned user struct.
  ///   - tweetFields: This fields parameter enables you to select which specific Tweet fields will deliver in each returned pinned Tweet. The Tweet fields will only return if the user has a pinned Tweet. While the referenced Tweet ID will be located in the original Tweet object, you will find this ID and all additional Tweet fields in the `includes` property on the returned `User`.
  /// - Returns: A `User` struct with the requested fields and expansions
  public func getMe(userFields: [User.Fields] = [], tweetFields: [Tweet.Fields] = []) async throws -> User {
    var components = getURLComponents(for: .me)
    components.queryItems = [
      URLQueryItem(name: "user.fields", value: userFields.map(\.rawValue).joined(separator: ",")),
      URLQueryItem(name: "tweet.fields", value: tweetFields.map(\.rawValue).joined(separator: ",")),
    ]
    
    if !tweetFields.isEmpty {
      components.queryItems?.append(URLQueryItem(name: "expansions", value: User.Expansions.pinned_tweet_id.rawValue))
    }
    
    let url = components.url!
    var userRequest = URLRequest(url: url)
    
    if let clientCredentials = clientCredentials {
      userRequest.oAuthSign(method: "GET", consumerCredentials: clientCredentials.helperTuple(), userCredentials: userCredentials?.helperTuple())
    } else if let bearerToken = bearerToken {
      userRequest.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    } else {
      throw TwiftError.MissingCredentialsError
    }
    
    let (data, _) = try await URLSession.shared.data(for: userRequest)
    
    let decoded = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
    
    print(decoded)
    
    if let error = decoded.error {
      throw error
    }
    
    guard var user = decoded.data else {
      throw TwiftError.UnknownError
    }
    
    if let includes = decoded.includes {
      user.includes = includes
    }
    
    return user
  }
}

public struct User: TwitterResource, Identifiable {
  public typealias ID = String
  public typealias Includes = UserIncludes
  
  /// The unique identifier of this user.
  public let id: ID
  
  /// The name of the user, as they’ve defined it on their profile. Not necessarily a person’s name. Typically capped at 50 characters, but subject to change.
  public let name: String
  
  /// The Twitter screen name, handle, or alias that this user identifies themselves with. Usernames are unique but subject to change. Typically a maximum of 15 characters long, but some historical accounts may exist with longer names.
  public let username: String
  
  /// The UTC datetime that the user account was created on Twitter.
  public let createdAt: Date?
  
  /// Indicates if this user has chosen to protect their Tweets (in other words, if this user's Tweets are private).
  public let protected: Bool?
  
  /// Contains withholding details for withheld content, if applicable.
  public let withheld: Withheld?
  
  /// The location specified in the user's profile, if the user provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries.
  public let location: String?
  
  /// Unique identifier of this user's pinned Tweet.
  public let pinnedTweetId: Tweet.ID?
  
  /// The URL specified in the user's profile, if present.
  public let url: URL?
  
  /// The text of this user's profile description (also known as bio), if the user provided one.
  public let description: String?
  
  /// Indicates if this user is a verified Twitter User.
  public let verified: Bool?
  
  /// Contains details about text that has a special meaning in the user's description.
  public let entities: Entities?
  
  /// The URL to the profile image for this user, as shown on the user's profile.
  public let profileImageUrl: URL?
  
  /// Contains details about activity for this user.
  public let publicMetrics: UserProfileMetrics?
  
  /// When including the `expansions=pinned_tweet_id` parameter, this includes the pinned Tweets attached to the returned users' profiles in the form of Tweet objects with their default fields and any additional fields requested using the `tweet.fields` parameter, assuming there is a referenced Tweet present in the returned Tweet(s).
  public var includes: UserIncludes?
  
  /// Any errors resulting from the request for this object
  public let errors: [TwitterResourceError]?
}

protocol EntityObject: Codable {
  var start: Int { get }
  var end: Int { get }
}

extension User {
  public struct UserIncludes: Codable {
    public let tweets: [Tweet]?
  }
  
  public struct UserProfileMetrics: Codable {
    public let followersCount: Int
    public let followingCount: Int
    public let listedCount: Int
  }
  
  public struct Withheld: Codable {
    public enum Scope: String, Codable {
      case tweet, user
    }
    
    public let countryCodes: [String]
    public let scope: Scope
  }
  
  public struct Entities: Codable {
    public let url: [URLEntity]?
    public let description: [DescriptionEntity]?
  }
  
  public struct DescriptionEntity: Codable {
    public let urls: [URLEntityDetails]?
    public let hashtags: [HashtagEntityDetails]?
    public let mentions: [MentionEntityDetails]?
    public let cashtags: [CashtagEntityDetails]?
  }
  
  public struct HashtagEntityDetails: EntityObject {
    public let start: Int
    public let end: Int
    public let hashtag: String
  }
  
  public struct MentionEntityDetails: EntityObject {
    public let start: Int
    public let end: Int
    public let username: String
  }
  
  public struct CashtagEntityDetails: EntityObject {
    public let start: Int
    public let end: Int
    public let cashtag: String
  }
  
  public struct URLEntity: Codable {
    public let urls: [URLEntityDetails]?
  }
  
  public struct URLEntityDetails: EntityObject {
    public let start: Int
    public let end: Int
    public let url: String
    public let expandedUrl: URL?
    public let displayUrl: String
  }
}

extension User {
  public enum Fields: String, Codable, CaseIterable {
    case created_at,
         description,
         entities,
         id,
         location,
         name,
         pinned_tweet_id,
         profile_image_url,
         protected,
         public_metrics,
         url,
         username,
         verified,
         withheld
  }
  
  public enum Expansions: String, Codable, CaseIterable {
    case pinned_tweet_id
  }
}
