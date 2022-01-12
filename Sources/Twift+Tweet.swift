//
//  File.swift
//  
//
//  Created by Daniel Eden on 12/01/2022.
//

import Foundation

struct Tweet: Codable {
  let id: String
  let text: String
  let attachments: Attachments?
  let authorId: String?
  // let contextAnnotations
  let conversationId: String?
  let createdAt: Date?
  let entities: Entities?
  let geo: Geo?
  let inReplyToUserId: String?
  let lang: String?
  let nonPublicMetrics: NonPublicMetrics?
  let organicMetrics: OrganicMetrics?
  let possiblySensitive: Bool?
  let promotedMetrics: PromotedMetrics?
  let publicMetrics: PublicMetrics?
  let referencedTweets: [ReferencedTweet]?
  let replySettings: ReplyAudience?
  let source: String?
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
