import XCTest
@testable import Twift

@MainActor
final class TwiftTests {
  static var userAuthClient: Twift {
    Twift(.oauth2UserAuth(OAuth2User(accessToken: "test", refreshToken: "test_refresh", scope: Set(OAuth2Scope.allCases)), onRefresh: { _ in }))
  }
  
  static var appOnlyClient: Twift {
    Twift(.appOnly(bearerToken: "123"))
  }
}
