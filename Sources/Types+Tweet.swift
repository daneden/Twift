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
    case following
    
    /// Only users mentioned in the Tweet can reply
    case mentionedUsers
  }
  
  public struct Attachments: Codable {
    public let pollIds: [String]?
    public let mediaKeys: [String]?
  }
  
  public struct Entities: Codable {
    public let annotations: [AnnotationEntity]?
    public let cashtags: [TagEntity]?
    public let hashtags: [TagEntity]?
    public let mentions: [MentionEntity]?
    public let urls: [URLEntity]?
  }
  
  public struct AnnotationEntity: EntityObject {
    public let start: Int
    public let end: Int
    public let probability: Double
    public let type: String
    public let normalizedText: String
  }
  
  public struct URLEntity: EntityObject {
    public let start: Int
    public let end: Int
    public let url: URL
    public let expandedUrl: URL
    public let displayUrl: String
    public let title: String?
    public let description: String?
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
      
      case retweeted
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

extension Tweet: PrivateFielded {
  /// Additional fields that can be requested for this Tweet
  public typealias Field = PartialKeyPath<Self>
  
  static internal func fieldName(field: PartialKeyPath<Tweet>) -> String? {
    switch field {
    case \.attachments: return "attachments"
    case \.authorId: return "author_id"
    // case context_annotations
    case \.conversationId: return "conversation_id"
    case \.createdAt: return "created_at"
    case \.entities: return "entities"
    case \.geo: return "geo"
    case \.inReplyToUserId: return "in_reply_to_user_id"
    case \.lang: return "lang"
    case \.nonPublicMetrics: return "non_public_metrics"
    case \.publicMetrics: return "public_metrics"
    case \.organicMetrics: return "organic_metrics"
    case \.promotedMetrics: return "promoted_metrics"
    case \.possiblySensitive: return "possibly_sensitive"
    case \.referencedTweets: return "referenced_tweets"
    case \.replySettings: return "reply_settings"
    case \.source: return "source"
    case \.withheld: return "withheld"
      
    default: return nil
    }
  }
  
  static internal var fieldParameterName = "tweet.fields"
  
  /// Publicly-available fields
  public static var publicFields: Set<Field> = [
    \.attachments,
     \.authorId,
     \.conversationId,
     \.createdAt,
     \.entities,
     \.geo,
     \.inReplyToUserId,
     \.lang,
     \.publicMetrics,
     \.possiblySensitive,
     \.referencedTweets,
     \.replySettings,
     \.source,
     \.withheld
  ]
  
  /// Fields that are only visible to the Tweet author or promoter
  public static var privateFields: Set<Field> = [
    \.nonPublicMetrics,
     \.organicMetrics,
     \.promotedMetrics
  ]
}

extension Tweet {
  /// A structure containing any requested expansions for this Tweet request
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
  public enum Expansions: Expansion {
    /// Expands associated Poll objects
    case pollIds(pollFields: Set<Poll.Field> = [])
    
    /// Expands associated Media objects
    case mediaKeys(mediaFields: Set<Media.Field> = [])
    
    /// Expands the User object of the Tweet author
    case authorId(userFields: Set<User.Field> = [])
    
    /// Expands the User objects of any mentioned users
    case mentionedUsernames(userFields: Set<User.Field> = [])
    
    /// Expands the Place details of any tagged place
    case geoPlaceId(placeFields: Set<Place.Field> = [])
    
    /// Expands the User object of the author of the tweet this tweet is replying to
    case inReplyToUserId(userFields: Set<User.Field> = [])
    
    /// Expands tweets that are quoted in this Tweet
    case referencedTweetsId
    
    /// Expands the User object of the author of the Tweet(s) this Tweet is referencing
    case referencedTweetsAuthorId(userFields: Set<User.Field> = [])
    
    internal var rawValue: String {
      switch self {
      case .pollIds: return "attachments.poll_ids"
      case .mediaKeys: return "attachments.media_keys"
      case .authorId: return "author_id"
      case .mentionedUsernames: return "entities.mentions.username"
      case .geoPlaceId: return "geo.place_id"
      case .inReplyToUserId: return "in_reply_to_user_id"
      case .referencedTweetsId: return "referenced_tweets.id"
      case .referencedTweetsAuthorId: return "referenced_tweets.id.author_id"
      }
    }
    
    internal var fields: URLQueryItem? {
      switch self {
      case .pollIds(let pollFields):
        if !pollFields.isEmpty { return URLQueryItem(name: Poll.fieldParameterName, value: pollFields.compactMap { Poll.fieldName(field: $0) }.joined(separator: ",")) }
      case .mediaKeys(let mediaFields):
        if !mediaFields.isEmpty { return URLQueryItem(name: Media.fieldParameterName, value: mediaFields.compactMap { Media.fieldName(field: $0) }.joined(separator: ",")) }
      case .geoPlaceId(let placeFields):
        if !placeFields.isEmpty { return URLQueryItem(name: Place.fieldParameterName, value: placeFields.compactMap { Place.fieldName(field: $0) }.joined(separator: ",")) }
      case .referencedTweetsId:
        return nil // nil because tweet.fields is defined on these requests already
      case .authorId(let userFields),
          .inReplyToUserId(let userFields),
          .mentionedUsernames(let userFields),
          .referencedTweetsAuthorId(let userFields):
        if !userFields.isEmpty { return URLQueryItem(name: User.fieldParameterName, value: userFields.compactMap { User.fieldName(field: $0) }.joined(separator: ",")) }
      }
      
      return nil
    }
  }
}
