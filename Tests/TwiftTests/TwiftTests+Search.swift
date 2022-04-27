//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftSearchTests: XCTestCase {
  func testSearchAllTweets() async throws {
    let searchAllTweetsResult = try await TwiftTests.userAuthClient.searchAllTweets(query: "test")
    XCTAssertEqual(searchAllTweetsResult.data.count, 1)
  }
  
  func testSearchRecentTweets() async throws {
    let searchRecentTweetsResult = try await TwiftTests.userAuthClient.searchRecentTweets(query: "test")
    XCTAssertEqual(searchRecentTweetsResult.data.count, 1)
  }
}
