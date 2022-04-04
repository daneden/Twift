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
}
