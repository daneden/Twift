//
//  File.swift
//  
//
//  Created by Daniel Eden on 13/01/2022.
//

import Foundation

public struct FollowResponse: Codable {
  public let following: Bool
  public let pendingFollow: Bool?
}
