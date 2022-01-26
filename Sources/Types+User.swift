import Foundation

/// The user object contains Twitter user account metadata describing the referenced user.
public struct User: Codable, Identifiable {
  public typealias ID = String
  
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
  public let withheld: WithheldInformation?
  
  /// The location specified in the user's profile, if the user provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries.
  public let location: String?
  
  /// Unique identifier of this user's pinned Tweet.
  public let pinnedTweetId: Tweet.ID?
  
  /// The URL specified in the user's profile, if present.
  public let url: String?
  
  /// The text of this user's profile description (also known as bio), if the user provided one.
  public let description: String?
  
  /// Indicates if this user is a verified Twitter User.
  public let verified: Bool?
  
  /// Contains details about text that has a special meaning in the user's description.
  public let entities: Entities?
  
  /// The URL to the profile image for this user, as shown on the user's profile.
  public let profileImageUrl: URL?
  
  /// A URL to larger version of the user's profile image
  public var profileImageUrlLarger: URL? {
    if let urlString = profileImageUrl?.absoluteString.replacingOccurrences(of: "_normal", with: "_x96") {
      return URL(string: urlString)
    } else {
      return profileImageUrl
    }
  }
  
  /// A URL to the original, unmodified version of the user's profile image. This image may be very large.
  public var profileImageUrlOriginal: URL? {
    if let urlString = profileImageUrl?.absoluteString.replacingOccurrences(of: "_normal", with: "_original") {
      return URL(string: urlString)
    } else {
      return profileImageUrl
    }
  }
  
  /// Contains details about activity for this user.
  public let publicMetrics: UserProfileMetrics?
}

extension User {
  /// Additional objects that can be requested with Users by expanding the `pinnedTweetId` field
  public struct Includes: Codable {
    public let tweets: [Tweet]
  }
  
  /// Public metrics relating to the user
  public struct UserProfileMetrics: Codable {
    /// The number of followers for this user
    public let followersCount: Int
    
    /// The number of users this user is following
    public let followingCount: Int
    
    /// The number of lists of which this user is a member
    public let listedCount: Int
  }
  
  /// Contains details about text that has a special meaning in the user's description
  public struct Entities: Codable {
    public let url: URLEntity?
    public let description: DescriptionEntity?
  }
  
  /// Contains details about text that has a special meaning in the user's description
  public struct DescriptionEntity: Codable {
    /// URL entities found in a user's profile description
    public let urls: [URLEntityDetails]?
    
    /// Hashtag entities found in a user's profile description
    public let hashtags: [TagEntity]?
    
    /// @mention entities found in a user's profile description
    public let mentions: [MentionEntity]?
    
    /// $cashtag entities found in a user's profile description
    public let cashtags: [TagEntity]?
  }
  
  /// Contains details about text that has a special meaning in the user's description
  public struct URLEntity: Codable {
    /// An array of URL entities found in the user's description
    public let urls: [URLEntityDetails]?
  }
  
  /// Contains details about text that has a special meaning in the user's description
  public struct URLEntityDetails: EntityObject {
    /// The start index for this entity in its containing string
    public let start: Int
    
    /// The end index for this entity in its containing string
    public let end: Int
    
    /// The UTF-8 text for the url entity
    public let url: String?
    
    /// The expanded URL, if any
    public let expandedUrl: URL?
    
    /// The UTF-8 display string for the url entity
    public let displayUrl: String?
  }
}

extension User: Fielded {
  /// Additional fields that can be requested for User objects
  public typealias Field = PartialKeyPath<User>
  
  static internal func fieldName(field: PartialKeyPath<User>) -> String? {
    switch field {
    case \.createdAt: return "created_at"
    case \.description: return "description"
    case \.entities: return "entities"
    case \.location: return "location"
    case \.pinnedTweetId: return "pinned_tweet_id"
    case \.profileImageUrl: return "profile_image_url"
    case \.protected: return "protected"
    case \.publicMetrics: return "public_metrics"
    case \.url: return "url"
    case \.verified: return "verified"
    case \.withheld: return "withheld"
      
    default: return nil
    }
  }
  
  static internal var fieldParameterName = "user.fields"
}

extension User: Expandable {
  /// Available object expansions for the ``User`` type
  public enum Expansions: Expansion {
    case pinnedTweetId(tweetFields: Set<Tweet.Field> = [])
    
    internal var fields: URLQueryItem? {
      switch self {
      case .pinnedTweetId(let tweetFields):
        if !tweetFields.isEmpty {
          return URLQueryItem(name: Tweet.fieldParameterName, value: tweetFields.compactMap { Tweet.fieldName(field: $0) }.joined(separator: ","))
        } else {
          return nil
        }
      }
    }
    
    internal var rawValue: String {
      switch self {
      case .pinnedTweetId(_):  return "pinned_tweet_id"
      }
    }
  }
}
