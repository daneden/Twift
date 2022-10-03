//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftLikeTests: XCTestCase {
  func testLikeTweet() async throws {
    let likeResult = try await TwiftTests.userAuthClient.likeTweet("0", userId: "1")
    XCTAssertTrue(likeResult.data.liked)
  }
  
  func testUnlikeTweet() async throws {
    let unlikeResult = try await TwiftTests.userAuthClient.unlikeTweet("0", userId: "1")
    XCTAssertTrue(unlikeResult.data.liked)
  }
  
  func testGetLikedTweets() async throws {
    let getLikedTweetsResult = try await TwiftTests.userAuthClient.getLikedTweets(for: "0")
    XCTAssertEqual(getLikedTweetsResult.data.count, 1)
  }
  
  func testGetLikingUsers() async throws {
    let getLikingUsers = try await TwiftTests.userAuthClient.getLikingUsers(for: "0")
    XCTAssertEqual(getLikingUsers.data.count, 1)
  }
}
