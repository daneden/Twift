import XCTest
@testable import Twift

@MainActor
final class TwiftTests: XCTestCase {
  var userAuthClient: Twift {
    Twift(.oauth2UserAuth(OAuth2User(accessToken: "test", refreshToken: "test_refresh", scope: Set(OAuth2Scope.allCases))))
  }
  
  func testUserRoutes() async throws {
    let getMeResult = try await userAuthClient.getMe()
    XCTAssertNotNil(getMeResult.data.id)
    
    let getUserResult = try await userAuthClient.getUser("0")
    XCTAssertNotNil(getUserResult.data.id)
    
    let getUsersResult = try await userAuthClient.getUsers(["0"])
    XCTAssertEqual(getUsersResult.data.count, 1)
    
    let getUserByResult = try await userAuthClient.getUserBy(username: "test")
    XCTAssertNotNil(getUserByResult.data.id)
    
    let getUsersByResult = try await userAuthClient.getUsersBy(usernames: ["test"])
    XCTAssertEqual(getUsersByResult.data.count, 1)
  }
  
  func testTweetRoutes() async throws {
    let userTimelineResult = try await userAuthClient.userTimeline("0")
    XCTAssertEqual(userTimelineResult.data.count, 1)
    
    let userMentionsResult = try await userAuthClient.userMentions("0")
    XCTAssertEqual(userMentionsResult.data.count, 1)
    
    let getTweetResult = try await userAuthClient.getTweet("0")
    XCTAssertNotNil(getTweetResult.data.id)
    
    let getTweetsResult = try await userAuthClient.getTweets(["0"])
    XCTAssertEqual(getTweetsResult.data.count, 1)
    
    let postTweetResult = try await userAuthClient.postTweet(MutableTweet(text: "Test"))
    XCTAssertNotNil(postTweetResult.data.id)
    
    let postComplexTweetResult = try await userAuthClient.postTweet(MutableTweet(text: "Test", poll: MutablePoll(options: ["1", "2"]), quoteTweetId: "1", reply: MutableTweet.Reply(inReplyToTweetId: "2"), replySettings: .following))
    XCTAssertNotNil(postComplexTweetResult.data.id)
    
    let deleteTweetResult = try await userAuthClient.deleteTweet("0")
    XCTAssertTrue(deleteTweetResult.data.deleted)
    
    let toggleHiddenResult = try await userAuthClient.toggleHiddenTweet("0", hidden: true)
    XCTAssertTrue(toggleHiddenResult.data.hidden)
    
    let hideReplyResult = try await userAuthClient.hideReply("0")
    XCTAssertTrue(hideReplyResult.data.hidden)
    
    let unhideReplyResult = try await userAuthClient.unhideReply("0")
    XCTAssertTrue(unhideReplyResult.data.hidden)
  }
  
  func testRetweetRoutes() async throws {
    let retweetResult = try await userAuthClient.retweet("0", userId: "0")
    XCTAssertTrue(retweetResult.data.retweeted)
    
    let unretweetResult = try await userAuthClient.unretweet("0", userId: "0")
    XCTAssertTrue(unretweetResult.data.retweeted)
    
    let retweetsResult = try await userAuthClient.retweets(for: "0")
    XCTAssertEqual(retweetsResult.data.count, 1)
    
    let quoteTweetsResult = try await userAuthClient.quoteTweets(for: "0")
    XCTAssertEqual(quoteTweetsResult.data.count, 1)
  }
}
