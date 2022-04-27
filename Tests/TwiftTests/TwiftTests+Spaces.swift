//
//  File.swift
//  
//
//  Created by Daniel Eden on 25/04/2022.
//

import XCTest

@MainActor
final class TwiftSpaceTests: XCTestCase {
  func testGetSpace() async throws {
    let getSpaceResult = try? await TwiftTests.userAuthClient.getSpace("0")
    // This assertion is a temporary workaround caused by a mistake in Twitter's OpenAPI spec: https://twittercommunity.com/t/openapi-space-is-ticketed-example-uses-wrong-value-type/170287
    XCTAssertNil(getSpaceResult)
    // XCTAssertNotNil(getSpaceResult.data.id)
  }
  
  func testGetSpaceBuyers() async throws {
    let getSpaceBuyersResult = try await TwiftTests.userAuthClient.getSpaceBuyers("0")
    XCTAssertEqual(getSpaceBuyersResult.data.count, 1)
  }
  
  func testGetSpaces() async throws {
    let getSpacesResult = try? await TwiftTests.userAuthClient.getSpaces(["0"])
    // This assertion is a temporary workaround caused by a mistake in Twitter's OpenAPI spec: https://twittercommunity.com/t/openapi-space-is-ticketed-example-uses-wrong-value-type/170287
    XCTAssertNil(getSpacesResult)
    // XCTAssertEqual(getSpacesResult.data.count, 1)
  }
  
  func testGetSpacesByCreatorIds() async throws {
    let getSpacesByCreatorIdsResult = try? await TwiftTests.userAuthClient.getSpacesByCreatorIds(["0"])
    // This assertion is a temporary workaround caused by a mistake in Twitter's OpenAPI spec: https://twittercommunity.com/t/openapi-space-is-ticketed-example-uses-wrong-value-type/170287
    XCTAssertNil(getSpacesByCreatorIdsResult)
    // XCTAssertEqual(getSpacesResult.data.count, 1)
  }
  
  func testGetSpaceTweets() async throws {
    let getSpaceTweetsResult = try await TwiftTests.userAuthClient.getSpaceTweets("0")
    XCTAssertEqual(getSpaceTweetsResult.data.count, 1)
  }
  
  func testSearchSpaces() async throws {
    let searchSpacesResult = try? await TwiftTests.userAuthClient.searchSpaces(query: "test")
    // This assertion is a temporary workaround caused by a mistake in Twitter's OpenAPI spec: https://twittercommunity.com/t/openapi-space-is-ticketed-example-uses-wrong-value-type/170287
    XCTAssertNil(searchSpacesResult)
    // XCTAssertEqual(getSpacesResult.data.count, 1)
  }
}
