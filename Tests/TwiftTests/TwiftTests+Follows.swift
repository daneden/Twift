//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftFollowTests: XCTestCase {
  func testFollowUser() async throws {
    let followResult = try await TwiftTests.userAuthClient.followUser(sourceUserId: "0", targetUserId: "1")
    XCTAssertTrue(followResult.data.following)
  }
  
  func testUnfollowUser() async throws {
    let unfollowResult = try await TwiftTests.userAuthClient.unfollowUser(sourceUserId: "0", targetUserId: "1")
    XCTAssertTrue(unfollowResult.data.following)
  }
  
  func testGetFollowing() async throws {
    let getFollowingResult = try await TwiftTests.userAuthClient.getFollowing("0")
    XCTAssertEqual(getFollowingResult.data.count, 1)
  }
  
  func testGetFollowers() async throws {
    let getFollowersResult = try await TwiftTests.userAuthClient.getFollowers("0")
    XCTAssertEqual(getFollowersResult.data.count, 1)
  }
}
