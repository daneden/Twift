//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftRetweetTests: XCTestCase {
  func testRetweet() async throws {
    let retweetResult = try await TwiftTests.userAuthClient.retweet("0", userId: "0")
    XCTAssertTrue(retweetResult.data.retweeted)
  }
  
  func testUnretweet() async throws {
    let unretweetResult = try await TwiftTests.userAuthClient.unretweet("0", userId: "0")
    XCTAssertTrue(unretweetResult.data.retweeted)
  }
  
  func testRetweets() async throws {
    let retweetsResult = try await TwiftTests.userAuthClient.retweets(for: "0")
    XCTAssertEqual(retweetsResult.data.count, 1)
  }
  
  func testQuoteTweets() async throws {
    let quoteTweetsResult = try await TwiftTests.userAuthClient.quoteTweets(for: "0")
    XCTAssertEqual(quoteTweetsResult.data.count, 1)
  }
}
