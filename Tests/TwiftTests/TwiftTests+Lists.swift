//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftListTests: XCTestCase {
  func testGetListTweets() async throws {
    let getListTweetsResult = try await TwiftTests.userAuthClient.getListTweets("0")
    XCTAssertEqual(getListTweetsResult.data.count, 1)
  }
  
  func testGetList() async throws {
    let getListResult = try await TwiftTests.userAuthClient.getList("0")
    XCTAssertNotNil(getListResult.data.id)
  }
   
  func testDeleteList() async throws {
    let deleteListResult = try await TwiftTests.userAuthClient.deleteList("0")
    XCTAssertTrue(deleteListResult.data.deleted)
  }
   
  func testGetListMembers() async throws {
    let getListMembersResult = try await TwiftTests.userAuthClient.getListMembers(for: "0")
    XCTAssertEqual(getListMembersResult.data.count, 1)
  }
  
  func testGetListMemberships() async throws {
    let getListMembershipsResult = try await TwiftTests.userAuthClient.getListMemberships(for: "0")
    XCTAssertEqual(getListMembershipsResult.data.count, 1)
  }
  
  func testGetUserOwnedLists() async throws {
    let getUserOwnedListsResult = try await TwiftTests.userAuthClient.getUserOwnedLists("0")
    XCTAssertEqual(getUserOwnedListsResult.data.count, 1)
  }
  
  func testCreateList() async throws {
    let createListResult = try await TwiftTests.userAuthClient.createList(name: "Test")
    XCTAssertNotNil(createListResult.data.id)
  }
  
  func testUpdateList() async throws {
    let updateListResult = try await TwiftTests.userAuthClient.updateList(id: "0", name: "Test", description: "Test Description")
    XCTAssertTrue(updateListResult.data.updated)
  }
  
  func testDeleteListMember() async throws {
    let deleteListMemberResult = try await TwiftTests.userAuthClient.deleteListMember("0", from: "0")
    XCTAssertTrue(deleteListMemberResult.data.isMember)
  }
  
  func testAddListMember() async throws {
    let addListMemberResult = try await TwiftTests.userAuthClient.addListMember("0", to: "0")
    XCTAssertTrue(addListMemberResult.data.isMember)
  }
  
  func testUnfollowList() async throws {
    let unfollowListResult = try await TwiftTests.userAuthClient.unfollowList("0", userId: "0")
    XCTAssertTrue(unfollowListResult.data.following)
  }
  
  func testFollowList() async throws {
    let followListResult = try await TwiftTests.userAuthClient.followList("0", userId: "0")
    XCTAssertTrue(followListResult.data.following)
  }
  
  func testGetListFollowers() async throws {
    let getListFollowersResult = try await TwiftTests.userAuthClient.getListFollowers("0")
    XCTAssertEqual(getListFollowersResult.data.count, 1)
  }
  
  func testGetFollowedLists() async throws {
    let getFollowedListsResult = try await TwiftTests.userAuthClient.getFollowedLists("0")
    XCTAssertEqual(getFollowedListsResult.data.count, 1)
  }
  
  func testPinList() async throws {
    let pinListResult = try await TwiftTests.userAuthClient.pinList("0", userId: "0")
    XCTAssertTrue(pinListResult.data.pinned)
  }
  
  func testUnpinList() async throws {
    let unpinListResult = try await TwiftTests.userAuthClient.unpinList("0", userId: "0")
    XCTAssertTrue(unpinListResult.data.pinned)
  }
  
  func testGetPinnedLists() async throws {
    let getPinnedListsResult = try await TwiftTests.userAuthClient.getPinnedLists("0")
    XCTAssertEqual(getPinnedListsResult.data.count, 1)
  }
}
