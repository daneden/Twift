//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftMuteTests: XCTestCase {
  func testMuteUser() async throws {
    let muteResult = try await TwiftTests.userAuthClient.muteUser(sourceUserId: "0", targetUserId: "1")
    XCTAssertTrue(muteResult.data.muting)
  }
  
  func testUnmuteUser() async throws {
    let unmuteResult = try await TwiftTests.userAuthClient.unmuteUser(sourceUserId: "0", targetUserId: "1")
    XCTAssertTrue(unmuteResult.data.muting)
  }
  
  func testGetMutedUsers() async throws {
    let getMutedUsersResult = try await TwiftTests.userAuthClient.getMutedUsers(for: "0")
    XCTAssertEqual(getMutedUsersResult.data.count, 1)
  }
}
