//
//  File.swift
//  
//
//  Created by Daniel Eden on 11/01/2022.
//

import Foundation

enum UserID {
  case id(_: String)
  case screenName(_: String)
}

extension Twift {
  func getUser(id: UserID) async throws {
    
  }
}

struct User: Codable, Identifiable {
  let id: String
  let name: String
  let username: String
  let createdAt: Date?
  let protected: Bool?
  let withheld: Withheld?
  let location: String?
  let url: String?
  let description: String?
  let verified: Bool?
  let entities: Entities?
  let profileImageUrl: URL?
  let publicMetrics: UserProfileMetrics?
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
