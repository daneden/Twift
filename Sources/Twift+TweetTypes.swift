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
  public enum ReplyAudience: String, Codable {
    case everyone, followers, mentionedUsers = "mentioned_users"
  }
  
  public struct WithheldInformation: Codable {
    let copyright: Bool
    let countryCodes: [String]
  }
  
  public struct Attachments: Codable {
    let pollIds: [String]?
    let mediaKeys: [String]?
  }
  
  public struct Entities: Codable {
    let annotations: [AnnotationEntity]?
    let cashtags: [TagEntity]?
    let hashtags: [TagEntity]?
    let mentions: [TagEntity]?
    let urls: [URLEntity]?
  }
  
  public struct AnnotationEntity: EntityObject {
    let start: Int
    let end: Int
    let probability: Double
    let type: String
    let normalizedText: String
  }
  
  public struct TagEntity: EntityObject {
    let start: Int
    let end: Int
    let tag: String
  }
  
  public struct URLEntity: EntityObject {
    let start: Int
    let end: Int
    let url: URL
    let expandedUrl: URL
    let displayUrl: String
    let status: Int
    let title: String?
    let description: String?
    let unwoundUrl: URL
  }
  
  public struct Geo: Codable {
    let coordinates: Coordinates
    let placeId: String
    
    struct Coordinates: Codable {
      let type: String
      let coordinates: [Double]
    }
  }
  
  public struct NonPublicMetrics: PrivateMetrics {
    let impressionCount: Int
    let urlLinkClicks: Int
    let userProfileClicks: Int
  }
  
  public struct OrganicMetrics: PrivateMetrics, PublicFacingMetrics {
    let impressionCount: Int
    let urlLinkClicks: Int
    let userProfileClicks: Int
    let likeCount: Int
    let replyCount: Int
    let retweetCount: Int
  }
  
  public struct PromotedMetrics: PrivateMetrics, PublicFacingMetrics {
    let impressionCount: Int
    let urlLinkClicks: Int
    let userProfileClicks: Int
    let likeCount: Int
    let replyCount: Int
    let retweetCount: Int
  }
  
  public struct PublicMetrics: PublicFacingMetrics {
    public let likeCount: Int
    public let replyCount: Int
    public let retweetCount: Int
    public let quoteCount: Int
  }
  
  public struct ReferencedTweet: Codable {
    public let id: String
    public let type: ReferenceType
    
    public enum ReferenceType: String, Codable {
      case quoted, repliedTo = "replied_to"
    }
  }
}

protocol PrivateMetrics: Codable {
  var impressionCount: Int { get }
  var urlLinkClicks: Int { get }
  var userProfileClicks: Int { get }
}

protocol PublicFacingMetrics: Codable {
  var likeCount: Int { get }
  var replyCount: Int { get }
  var retweetCount: Int { get }
}

extension Tweet {
  public enum Fields: String, Codable {
    case attachments
    case author_id
    case context_annotations
    case conversation_id
    case created_at
    case entities
    case geo
    case id
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
    case text
    case withheld
  }
  
  public enum Expansions: String, Codable {
    case pollIds = "attachments.poll_ids"
    case mediaKeys = "attachments.media_keys"
    case author_id
    case mentionedUsers = "entities.mentions.username"
    case placeId = "geo.place_id"
    case in_reply_to_user_id
    case referencedTweetIds = "referenced_tweets.id"
    case referencedTweetAuthorIds = "referenced_tweets.id.author_id"
  }
}
