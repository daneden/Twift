import Foundation

public struct Tweet: Codable, Identifiable {
  public typealias ID = String
  
  /// The unique identifier of the represented Tweet
  public let id: ID
  
  /// The actual UTF-8 text of the Tweet.
  public let text: String
  
  /// Specifies the type of attachments (if any) present in this Tweet
  public let attachments: Attachments?
  
  /// The unique identifier of the User who posted this Tweet.
  public let authorId: User.ID?
  
  // let contextAnnotations
  
  /// The Tweet ID of the original Tweet of the conversation (which includes direct replies, replies of replies)
  public let conversationId: Tweet.ID?
  
  /// Creation time of the Tweet
  public let createdAt: Date?
  
  /// Entities which have been parsed out of the text of the Tweet.
  public let entities: Entities?
  
  /// Contains details about the location tagged by the user in this Tweet, if they specified one.
  public let geo: Geo?
  
  /// If the represented Tweet is a reply, this field will contain the original Tweet’s author ID. This will not necessarily always be the user directly mentioned in the Tweet.
  public let inReplyToUserId: User.ID?
  
  /// Language of the Tweet, if detected by Twitter. Returned as a BCP47 language tag.
  public let lang: String?
  
  /// Non-public engagement metrics for the Tweet at the time of the request. Requires user context authentication.
  public let nonPublicMetrics: NonPublicMetrics?
  
  /// Engagement metrics, tracked in an organic context, for the Tweet at the time of the request. Requires user context authentication.
  public let organicMetrics: OrganicMetrics?
  
  /// This field only surfaces when a Tweet contains a link. The meaning of the field doesn’t pertain to the Tweet content itself, but instead it is an indicator that the URL contained in the Tweet may contain content or media identified as sensitive content.
  public let possiblySensitive: Bool?
  
  /// Engagement metrics, tracked in a promoted context, for the Tweet at the time of the request. Requires user context authentication.
  public let promotedMetrics: PromotedMetrics?
  
  /// Public engagement metrics for the Tweet at the time of the request.
  public let publicMetrics: PublicMetrics?
  
  /// A list of Tweets this Tweet refers to. For example, if the parent Tweet is a Retweet, a Retweet with comment (also known as Quoted Tweet) or a Reply, it will include the related Tweet referenced to by its parent.
  public let referencedTweets: [ReferencedTweet]?
  
  /// Shows you who can reply to a given Tweet.
  public let replySettings: ReplyAudience?
  
  /// The name of the app the user Tweeted from.
  public let source: String?
  
  /// When present, contains withholding details for withheld content.
  public let withheld: WithheldInformation?
}

extension Tweet {
  /// The audience that can reply to an associated Tweet
  public enum ReplyAudience: String, Codable {
    /// Everyone on Twitter can reply to the associated Tweet
    case everyone
    
    /// Only users who follow the Tweet author can reply
    case followers
    
    /// Only users mentioned in the Tweet can reply
    case mentionedUsers = "mentioned_users"
  }
  
  public struct Attachments: Codable {
    let pollIds: [String]?
    let mediaKeys: [String]?
  }
  
  public struct Entities: Codable {
    let annotations: [AnnotationEntity]?
    let cashtags: [TagEntity]?
    let hashtags: [TagEntity]?
    let mentions: [MentionEntity]?
    let urls: [URLEntity]?
  }
  
  public struct AnnotationEntity: EntityObject {
    let start: Int
    let end: Int
    let probability: Double
    let type: String
    let normalizedText: String
  }
  
  public struct URLEntity: EntityObject {
    let start: Int
    let end: Int
    let url: URL
    let expandedUrl: URL
    let displayUrl: String
    let title: String?
    let description: String?
  }
  
  /// Tweet engagement metrics only visible to the Tweet author/promoter
  public struct NonPublicMetrics: PrivateMetrics {
    /// The number of impressions for this Tweet
    public let impressionCount: Int
    
    /// The number of clicks on URLs contained in this Tweet
    public let urlLinkClicks: Int?
    
    /// The number of profile visits originating from this Tweet
    public let userProfileClicks: Int
  }
  
  /// Tweet engagement metrics only visible to the Tweet author/promoter
  public struct OrganicMetrics: PrivateMetrics, PublicFacingMetrics {
    /// The number of impressions for this Tweet
    public let impressionCount: Int
    
    /// The number of clicks on URLs contained in this Tweet
    public let urlLinkClicks: Int?
    
    /// The number of profile visits originating from this Tweet
    public let userProfileClicks: Int
    
    /// The number of likes for this Tweet
    public let likeCount: Int
    
    /// The number of replies for this Tweet
    public let replyCount: Int
    
    /// The number of Retweets for this Tweet
    public let retweetCount: Int
  }
  
  /// Tweet engagement metrics only visible to the Tweet author/promoter
  public struct PromotedMetrics: PrivateMetrics, PublicFacingMetrics {
    /// The number of impressions for this Tweet
    public let impressionCount: Int
    
    /// The number of clicks on URLs contained in this Tweet
    public let urlLinkClicks: Int?
    
    /// The number of profile visits originating from this Tweet
    public let userProfileClicks: Int
    
    /// The number of likes for this Tweet
    public let likeCount: Int
    
    /// The number of replies for this Tweet
    public let replyCount: Int
    
    /// The number of Retweets for this Tweet
    public let retweetCount: Int
  }
  
  /// Tweet engagement metrics that are visible to everyone on Twitter
  public struct PublicMetrics: PublicFacingMetrics {
    /// The number of likes for this Tweet
    public let likeCount: Int
    
    /// The number of replies for this Tweet
    public let replyCount: Int
    
    /// The number of Retweets for this Tweet
    public let retweetCount: Int
    
    /// The number of times this Tweet has been quoted
    public let quoteCount: Int
  }
  
  public struct ReferencedTweet: Codable {
    /// The ID for this referenced Tweet
    public let id: String
    
    /// The type of reference for this referenced Tweet
    public let type: ReferenceType
    
    /// The type of reference for referenced Tweets
    public enum ReferenceType: String, Codable {
      /// The referenced Tweet was quoted in the author's Tweet
      case quoted
      
      /// The author's Tweet was a reply to the referenced Tweet
      case repliedTo = "replied_to"
    }
  }
}

/// Tweet engagement metrics only visible to the Tweet author/promoter
protocol PrivateMetrics: Codable {
  /// The number of impressions for this Tweet
  var impressionCount: Int { get }
  
  /// The number of clicks on URLs contained in this Tweet
  var urlLinkClicks: Int? { get }
  
  /// The number of profile visits originating from this Tweet
  var userProfileClicks: Int { get }
}

/// Tweet engagement metrics that are visible to everyone on Twitter
protocol PublicFacingMetrics: Codable {
  /// The number of likes for this Tweet
  var likeCount: Int { get }
  
  /// The number of replies for this Tweet
  var replyCount: Int { get }
  
  /// The number of Retweets and Quoted Tweets for this Tweet
  var retweetCount: Int { get }
}

extension Tweet: PrivateFields {
  /// Optional fields that can be requested for Tweet objects
  public enum Fields: String, Codable, CaseIterable {
    case attachments
    case author_id
    case context_annotations
    case conversation_id
    case created_at
    case entities
    case geo
    case in_reply_to_user_id
    case lang
    case non_public_metrics
    case public_metrics
    case organic_metrics
    case promoted_metrics
    case possibly_sensitive
    case referenced_tweets
    case reply_settings
    case source
    case withheld
  }
  
  /// Publicly-available fields
  public static var publicFields: [Fields] {
    Tweet.Fields.allCases.filter {
      switch $0 {
      case .non_public_metrics,
          .promoted_metrics,
          .organic_metrics: return false
      default: return true
      }
    }
  }
  
  /// Fields that are only visible to the Tweet author or promoter
  public static var privateFields: [Fields] {
    Tweet.Fields.allCases.filter {
      switch $0 {
      case .non_public_metrics,
          .promoted_metrics,
          .organic_metrics: return true
      default: return false
      }
    }
  }
}

extension Tweet {
  public struct Includes: Codable {
    public let users: [User]?
    public let tweets: [Tweet]?
    public let media: [Media]?
    public let polls: [Poll]?
    public let places: [Place]?
  }
}

extension Tweet: Expandable {
  /// Available fields that can be expanded on Tweet objects
  public enum Expansions: String, CaseIterable {
    case pollIds = "attachments.poll_ids"
    case mediaKeys = "attachments.media_keys"
    case authorId = "author_id"
    case mentionedUsernames = "entities.mentions.username"
    case geoPlaceId = "geo.place_id"
    case inReplyToUserId = "in_reply_to_user_id"
    case referencedTweetsId = "referenced_tweets.id"
    case referencedTweetsAuthorId = "referenced_tweets.id.author_id"
  }
  
  static var expansions: [Expansion] {
    Expansions.allCases.map { $0.rawValue }
  }
}
