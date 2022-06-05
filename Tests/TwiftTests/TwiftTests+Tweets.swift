//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest
@testable import Twift

@MainActor
final class TwiftTweetTests: XCTestCase {
  func testUserTimeline() async throws {
    let userTimelineResult = try await TwiftTests.userAuthClient.userTimeline("0")
    XCTAssertEqual(userTimelineResult.data.count, 1)
  }
  
  func testUserMentions() async throws {
    let userMentionsResult = try await TwiftTests.userAuthClient.userMentions("0")
    XCTAssertEqual(userMentionsResult.data.count, 1)
  }
  
  func testReverseChronologicalTimeline() async throws {
    let userMentionsResult = try await TwiftTests.userAuthClient.reverseChronologicalTimeline("0")
    XCTAssertEqual(userMentionsResult.data.count, 1)
  }
  
  func testGetTweet() async throws {
    let getTweetResult = try await TwiftTests.userAuthClient.getTweet("0")
    XCTAssertNotNil(getTweetResult.data.id)
  }
  
  func testGetTweets() async throws {
    let getTweetsResult = try await TwiftTests.userAuthClient.getTweets(["0"])
    XCTAssertEqual(getTweetsResult.data.count, 1)
  }
  
  func testPostTweet() async throws {
    let postTweetResult = try await TwiftTests.userAuthClient.postTweet(MutableTweet(text: "Test"))
    XCTAssertNotNil(postTweetResult.data.id)
  }
  
  func testPostTweetComplex() async throws {
    let postComplexTweetResult = try await TwiftTests.userAuthClient.postTweet(
      MutableTweet(text: "Test",
                   poll: MutablePoll(options: ["1", "2"]),
                   quoteTweetId: "1",
                   reply: MutableTweet.Reply(inReplyToTweetId: "2"),
                   replySettings: .following)
    )
    XCTAssertNotNil(postComplexTweetResult.data.id)
  }
  
  func testDeleteTweet() async throws {
    let deleteTweetResult = try await TwiftTests.userAuthClient.deleteTweet("0")
    XCTAssertTrue(deleteTweetResult.data.deleted)
  }
  
  func testHideReply() async throws {
    let hideReplyResult = try await TwiftTests.userAuthClient.hideReply("0")
    XCTAssertTrue(hideReplyResult.data.hidden)
  }
  
  func testUnhideReply() async throws {
    let unhideReplyResult = try await TwiftTests.userAuthClient.unhideReply("0")
    XCTAssertTrue(unhideReplyResult.data.hidden)
  }
}
