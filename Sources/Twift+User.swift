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
      let url = URL(string: "https://api.twitter.com/2/users/by/username/\(unwrappedScreenName)")!
      var userIdRequest = URLRequest(url: url)
      
      userIdRequest.oAuthSign(method: "GET", consumerCredentials: (key: clientCredentials.key, secret: clientCredentials.secret))
      
      let (data, _) = try await URLSession.shared.data(for: userIdRequest)
      
      guard let user = try decoder.decode(TwitterAPIResponse<User>.self, from: data).data else {
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
    
    let url = URL(string: "https://api.twitter.com/2/users/\(userId)")!
    var userRequest = URLRequest(url: url)
    
    userRequest.oAuthSign(method: "GET", consumerCredentials: clientCredentials.helperTuple(), userCredentials: userCredentials?.helperTuple())

    let (data, _) = try await URLSession.shared.data(for: userRequest)
    
    let decoding = try decoder.decode(TwitterAPIResponse<User>.self, from: data)
    
    if let user = decoding.data {
      return user
    } else {
      throw TwitterAPIError(title: decoding.title, detail: decoding.detail, type: decoding.type)
    }
  }
}

public struct User: Codable, Identifiable {
  public typealias ID = String
  
  /// The unique identifier of this user.
  public let id: ID
  
  /// The name of the user, as they’ve defined it on their profile. Not necessarily a person’s name. Typically capped at 50 characters, but subject to change.
  let name: String
  
  /// The Twitter screen name, handle, or alias that this user identifies themselves with. Usernames are unique but subject to change. Typically a maximum of 15 characters long, but some historical accounts may exist with longer names.
  let username: String
  
  /// The UTC datetime that the user account was created on Twitter.
  let createdAt: Date?
  
  /// Indicates if this user has chosen to protect their Tweets (in other words, if this user's Tweets are private).
  let protected: Bool?
  
  /// Contains withholding details for withheld content, if applicable.
  let withheld: Withheld?
  
  /// The location specified in the user's profile, if the user provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries.
  let location: String?
  
  /// Unique identifier of this user's pinned Tweet.
  let pinnedTweetId: Tweet.ID?
  
  /// The URL specified in the user's profile, if present.
  let url: URL?
  
  /// The text of this user's profile description (also known as bio), if the user provided one.
  let description: String?
  
  /// Indicates if this user is a verified Twitter User.
  let verified: Bool?
  
  /// Contains details about text that has a special meaning in the user's description.
  let entities: Entities?
  
  /// The URL to the profile image for this user, as shown on the user's profile.
  let profileImageUrl: URL?
  
  /// Contains details about activity for this user.
  let publicMetrics: UserProfileMetrics?
  
  /// When including the `expansions=pinned_tweet_id` parameter, this includes the pinned Tweets attached to the returned users' profiles in the form of Tweet objects with their default fields and any additional fields requested using the `tweet.fields` parameter, assuming there is a referenced Tweet present in the returned Tweet(s).
  let includes: UserIncludes?
}

protocol EntityObject: Codable {
  var start: Int { get }
  var end: Int { get }
}

extension User {
  struct UserIncludes: Codable {
    let tweets: [Tweet]?
  }
  
  struct UserProfileMetrics: Codable {
    let followersCount: Int
    let followingCount: Int
    let listedCount: Int
  }
  
  struct Withheld: Codable {
    enum Scope: String, Codable {
      case tweet, user
    }
    
    let countryCodes: [String]
    let scope: Scope
  }
  
  struct Entities: Codable {
    let url: [URLEntity]?
    let description: [DescriptionEntity]?
  }
  
  struct DescriptionEntity: Codable {
    let urls: [URLEntityDetails]?
    let hashtags: [HashtagEntityDetails]?
    let mentions: [MentionEntityDetails]?
    let cashtags: [CashtagEntityDetails]?
  }
  
  struct HashtagEntityDetails: EntityObject {
    let start: Int
    let end: Int
    let hashtag: String
  }
  
  struct MentionEntityDetails: EntityObject {
    let start: Int
    let end: Int
    let username: String
  }
  
  struct CashtagEntityDetails: EntityObject {
    let start: Int
    let end: Int
    let cashtag: String
  }
  
  struct URLEntity: Codable {
    let urls: [URLEntityDetails]?
  }
  
  struct URLEntityDetails: EntityObject {
    let start: Int
    let end: Int
    let url: String
    let expandedUrl: URL?
    let displayUrl: String
  }
}

extension User {
  public enum Fields: String, Codable {
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
  
  public enum Expansions: String, Codable {
    case pinned_tweet_id
  }
}
