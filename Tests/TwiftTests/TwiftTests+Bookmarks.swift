//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftBookmarkTests: XCTestCase {
  func testAddBookmark() async throws {
    let addBookmarkTest = try await TwiftTests.userAuthClient.addBookmark("0", userId: "0")
    XCTAssertTrue(addBookmarkTest.data.bookmarked)
  }
  
  func testDeleteBookmark() async throws {
    let deleteBookmarkTest = try await TwiftTests.userAuthClient.deleteBookmark("0", userId: "0")
    XCTAssertTrue(deleteBookmarkTest.data.bookmarked)
  }
  
  func testGetBookmarks() async throws {
    let getBookmarksTest = try await TwiftTests.userAuthClient.getBookmarks(for: "0")
    XCTAssertEqual(getBookmarksTest.data.count, 1)
  }
}
