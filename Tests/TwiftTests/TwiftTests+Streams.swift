//
//  File.swift
//  
//
//  Created by Daniel Eden on 27/04/2022.
//

import XCTest
@testable import Twift

@MainActor
final class TwiftStreamsTests: XCTestCase {
  func testGetFilteredStreamRules() async throws {
    let getFilteredStreamRulesResult = try await TwiftTests.userAuthClient.getFilteredStreamRules()
     XCTAssertEqual(getFilteredStreamRulesResult.data?.count, 1)
  }
  
  func testFilteredStream() async throws {
    let filteredStreamResult = try await TwiftTests.appOnlyClient.filteredStream()
    
    for try await result in filteredStreamResult {
      XCTAssertNotNil(result.data.id)
      break
    }
  }
  
  func testModifyFilteredStreamRules() async throws {
    let ruleToAdd = MutableFilteredStreamRule(value: "test")
    let modifyFilteredStreamRulesDryRunResult = try await TwiftTests.appOnlyClient.modifyFilteredStreamRules(add: [ruleToAdd], delete: ["0"])
    XCTAssertNotNil(modifyFilteredStreamRulesDryRunResult.meta)
  }
  
  func testVolumeStream() async throws {
    let volumeStreamResult = try await TwiftTests.appOnlyClient.volumeStream()
    
    for try await result in volumeStreamResult {
      XCTAssertNotNil(result.data.id)
      break
    }
  }
}
