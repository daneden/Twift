//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest
import Twift

@MainActor
final class TwiftBlockTests: XCTestCase {
  func testBlockUser() async throws {
    let blockUserResult = try await TwiftTests.userAuthClient.blockUser(sourceUserId: "0", targetUserId: "1")
    XCTAssertTrue(blockUserResult.data.blocking)
  }
  
  func testUnblockUser() async throws {
    let blockUserResult = try await TwiftTests.userAuthClient.unblockUser(sourceUserId: "0", targetUserId: "1")
    XCTAssertTrue(blockUserResult.data.blocking)
  }
  
  func testGetBlockedUsers() async throws {
    let getBlockedUsersResult = try await TwiftTests.userAuthClient.getBlockedUsers(for: "0")
    XCTAssertEqual(getBlockedUsersResult.data.count, 1)
  }
}
