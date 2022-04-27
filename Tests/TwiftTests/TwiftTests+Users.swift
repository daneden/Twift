//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftUserTests: XCTestCase {
  func testGetMe() async throws {
    let getMeResult = try await TwiftTests.userAuthClient.getMe()
    XCTAssertNotNil(getMeResult.data.id)
  }
  
  func testGetUser() async throws {
    let getUserResult = try await TwiftTests.userAuthClient.getUser("0")
    XCTAssertNotNil(getUserResult.data.id)
  }
  
  func testGetUsers() async throws {
    let getUsersResult = try await TwiftTests.userAuthClient.getUsers(["0"])
    XCTAssertEqual(getUsersResult.data.count, 1)
  }
  
  func testGetUserBy() async throws {
    let getUserByResult = try await TwiftTests.userAuthClient.getUserBy(username: "test")
    XCTAssertNotNil(getUserByResult.data.id)
  }
  
  func testGetUsersBy() async throws {
    let getUsersByResult = try await TwiftTests.userAuthClient.getUsersBy(usernames: ["test"])
    XCTAssertEqual(getUsersByResult.data.count, 1)
  }
}
