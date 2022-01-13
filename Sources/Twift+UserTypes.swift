import Foundation

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
  
  /// Any errors resulting from the request for this object
  public let errors: [TwitterResourceError]?
}

extension User {
  public struct Includes: Codable {
    public let tweets: [Tweet]
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
