import XCTest
@testable import Twift

@MainActor
final class TwiftTests: XCTestCase {
  var userAuthClient: Twift {
    Twift(.oauth2UserAuth(OAuth2User(accessToken: "test", refreshToken: "test_refresh", scope: Set(OAuth2Scope.allCases))))
  }
  
  func testUserMethods() async throws {
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
  
  func testTweetMethods() async throws {
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
  
  func testRetweetMethods() async throws {
    let retweetResult = try await userAuthClient.retweet("0", userId: "0")
    XCTAssertTrue(retweetResult.data.retweeted)
    
    let unretweetResult = try await userAuthClient.unretweet("0", userId: "0")
    XCTAssertTrue(unretweetResult.data.retweeted)
    
    let retweetsResult = try await userAuthClient.retweets(for: "0")
    XCTAssertEqual(retweetsResult.data.count, 1)
    
    let quoteTweetsResult = try await userAuthClient.quoteTweets(for: "0")
    XCTAssertEqual(quoteTweetsResult.data.count, 1)
  }
  
  func testBookmarkMethods() async throws {
    let addBookmarkTest = try await userAuthClient.addBookmark("0", userId: "0")
    XCTAssertTrue(addBookmarkTest.data.bookmarked)
    
    let deleteBookmarkTest = try await userAuthClient.deleteBookmark("0", userId: "0")
    XCTAssertTrue(deleteBookmarkTest.data.bookmarked)
    
    let getBookmarksTest = try await userAuthClient.getBookmarks(for: "0")
    XCTAssertEqual(getBookmarksTest.data.count, 1)
  }
  
  func testListMethods() async throws {
    let getListTweetsResult = try await userAuthClient.getListTweets("0")
    XCTAssertEqual(getListTweetsResult.data.count, 1)
    
    let getListResult = try await userAuthClient.getList("0")
    XCTAssertNotNil(getListResult.data.id)
    
    let deleteListResult = try await userAuthClient.deleteList("0")
    XCTAssertTrue(deleteListResult.data.deleted)
    
    let getListMembersResult = try await userAuthClient.getListMembers(for: "0")
    XCTAssertEqual(getListMembersResult.data.count, 1)
    
    let getListMembershipsResult = try await userAuthClient.getListMemberships(for: "0")
    XCTAssertEqual(getListMembershipsResult.data.count, 1)
    
    let getUserOwnedListsResult = try await userAuthClient.getUserOwnedLists("0")
    XCTAssertEqual(getUserOwnedListsResult.data.count, 1)
    
    let createListResult = try await userAuthClient.createList(name: "Test")
    XCTAssertNotNil(createListResult.data.id)
    
    let updateListResult = try await userAuthClient.updateList(id: "0", name: "Test", description: "Test Description")
    XCTAssertTrue(updateListResult.data.updated)
    
    let deleteListMemberResult = try await userAuthClient.deleteListMember("0", from: "0")
    XCTAssertTrue(deleteListMemberResult.data.isMember)
    
    let addListMemberResult = try await userAuthClient.addListMember("0", to: "0")
    XCTAssertTrue(addListMemberResult.data.isMember)
    
    let unfollowListResult = try await userAuthClient.unfollowList("0", userId: "0")
    XCTAssertTrue(unfollowListResult.data.following)
    
    let followListResult = try await userAuthClient.followList("0", userId: "0")
    XCTAssertTrue(followListResult.data.following)
    
    let getListFollowersResult = try await userAuthClient.getListFollowers("0")
    XCTAssertEqual(getListFollowersResult.data.count, 1)
    
    let getFollowedListsResult = try await userAuthClient.getFollowedLists("0")
    XCTAssertEqual(getFollowedListsResult.data.count, 1)
    
    let pinListResult = try await userAuthClient.pinList("0", userId: "0")
    XCTAssertTrue(pinListResult.data.pinned)
    
    let unpinListResult = try await userAuthClient.unpinList("0", userId: "0")
    XCTAssertTrue(unpinListResult.data.pinned)
    
    let getPinnedListsResult = try await userAuthClient.getPinnedLists("0")
    XCTAssertEqual(getPinnedListsResult.data.count, 1)
  }
}
