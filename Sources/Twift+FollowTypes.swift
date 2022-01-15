//
//  File.swift
//  
//
//  Created by Daniel Eden on 13/01/2022.
//

import Foundation

/// A response object containing information relating to a follow status.
public struct FollowResponse: Codable {
  /// Indicates whether the id is following the specified user as a result of this request. This value is false if the target user does not have public Tweets, as they will have to approve the follower request.
  public let following: Bool
  
  /// Indicates whether the target user will need to approve the follow request. Note that the authenticated user will follow the target user only when they approve the incoming follower request.
  public let pendingFollow: Bool?
}
