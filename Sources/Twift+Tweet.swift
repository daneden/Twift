//
//  File.swift
//  
//
//  Created by Daniel Eden on 12/01/2022.
//

import Foundation

public struct Tweet: Codable, Identifiable {
  public typealias ID = String
  
  /// The unique identifier of the represented Tweet
  public let id: ID
  
  /// The actual UTF-8 text of the Tweet.
  let text: String
  
  /// Specifies the type of attachments (if any) present in this Tweet
  let attachments: Attachments?
  
  /// The unique identifier of the User who posted this Tweet.
  let authorId: User.ID?
  
  // let contextAnnotations
  
  /// The Tweet ID of the original Tweet of the conversation (which includes direct replies, replies of replies)
  let conversationId: Tweet.ID
  
  /// Creation time of the Tweet
  let createdAt: Date?
  
  /// Entities which have been parsed out of the text of the Tweet.
  let entities: Entities?
  
  /// Contains details about the location tagged by the user in this Tweet, if they specified one.
  let geo: Geo?
  
  /// If the represented Tweet is a reply, this field will contain the original Tweet’s author ID. This will not necessarily always be the user directly mentioned in the Tweet.
  let inReplyToUserId: User.ID
  
  /// Language of the Tweet, if detected by Twitter. Returned as a BCP47 language tag.
  let lang: String?
  
  /// Non-public engagement metrics for the Tweet at the time of the request. Requires user context authentication.
  let nonPublicMetrics: NonPublicMetrics?
  
  /// Engagement metrics, tracked in an organic context, for the Tweet at the time of the request. Requires user context authentication.
  let organicMetrics: OrganicMetrics?
  
  /// This field only surfaces when a Tweet contains a link. The meaning of the field doesn’t pertain to the Tweet content itself, but instead it is an indicator that the URL contained in the Tweet may contain content or media identified as sensitive content.
  let possiblySensitive: Bool?
  
  /// Engagement metrics, tracked in a promoted context, for the Tweet at the time of the request. Requires user context authentication.
  let promotedMetrics: PromotedMetrics?
  
  /// Public engagement metrics for the Tweet at the time of the request.
  let publicMetrics: PublicMetrics?
  
  /// A list of Tweets this Tweet refers to. For example, if the parent Tweet is a Retweet, a Retweet with comment (also known as Quoted Tweet) or a Reply, it will include the related Tweet referenced to by its parent.
  let referencedTweets: [ReferencedTweet]?
  
  /// Shows you who can reply to a given Tweet.
  let replySettings: ReplyAudience?
  
  /// The name of the app the user Tweeted from.
  let source: String?
  
  /// When present, contains withholding details for withheld content.
  let withheld: WithheldInformation?
}

extension Tweet {
  enum ReplyAudience: String, Codable {
    case everyone, followers, mentionedUsers = "mentioned_users"
  }
  
  struct WithheldInformation: Codable {
    let copyright: Bool
    let countryCodes: [String]
  }
  
  struct Attachments: Codable {
    let pollIds: [String]?
    let mediaKeys: [String]?
  }
  
  struct Entities: Codable {
    let annotations: [AnnotationEntity]?
    let cashtags: [TagEntity]?
    let hashtags: [TagEntity]?
    let mentions: [TagEntity]?
    let urls: [URLEntity]?
  }
  
  struct AnnotationEntity: EntityObject {
    let start: Int
    let end: Int
    let probability: Double
    let type: String
    let normalizedText: String
  }
  
  struct TagEntity: EntityObject {
    let start: Int
    let end: Int
    let tag: String
  }
  
  struct URLEntity: EntityObject {
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
  
  struct Geo: Codable {
    let coordinates: Coordinates
    let placeId: String
    
    struct Coordinates: Codable {
      let type: String
      let coordinates: [Double]
    }
  }
  
  struct NonPublicMetrics: PrivateMetrics {
    let impressionCount: Int
    let urlLinkClicks: Int
    let userProfileClicks: Int
  }
  
  struct OrganicMetrics: PrivateMetrics, PublicFacingMetrics {
    let impressionCount: Int
    let urlLinkClicks: Int
    let userProfileClicks: Int
    let likeCount: Int
    let replyCount: Int
    let retweetCount: Int
  }
  
  struct PromotedMetrics: PrivateMetrics, PublicFacingMetrics {
    let impressionCount: Int
    let urlLinkClicks: Int
    let userProfileClicks: Int
    let likeCount: Int
    let replyCount: Int
    let retweetCount: Int
  }
  
  struct PublicMetrics: PublicFacingMetrics {
    let likeCount: Int
    let replyCount: Int
    let retweetCount: Int
    let quoteCount: Int
  }
  
  struct ReferencedTweet: Codable {
    let id: String
    let type: ReferenceType
    
    enum ReferenceType: String, Codable {
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
  public enum Fields: String {
    case attachments,
         author_id,
         conversation_id,
         created_at,
         entities,
         geo,
         id,
         in_reply_to_user_id,
         lang,
         non_public_metrics,
         public_metrics,
         organic_metrics,
         promoted_metrics,
         possibly_sensitive,
         referenced_tweets,
         reply_settings,
         source,
         text,
         withheld
  }
}
