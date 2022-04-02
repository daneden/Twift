import Foundation
import Combine

@MainActor
public class Twift: NSObject, ObservableObject {
  /// The type of authentication access for this Twift instance
  public private(set) var authenticationType: AuthenticationType
  
  internal let decoder: JSONDecoder
  internal let encoder: JSONEncoder
  
  /// Initialise an instance with the specified authentication type
  public init(_ authenticationType: AuthenticationType) {
    self.authenticationType = authenticationType
    
    self.decoder = Self.initializeDecoder()
    self.encoder = Self.initializeEncoder()
  }
  
  /// A convenience variable for accessing the currently-authenticated User ID.
  /// This allows user-authenticating methods to treat actor user IDs as optional, making callsites simpler.
  internal var authenticatedUserId: User.ID? {
    switch authenticationType {
    case .userAccessTokens(_, let userCredentials):
      return userCredentials.userId
    case .appOnly(_):
      return nil
    case .oauth2UserAuth(_):
      return nil
    }
  }
  
  /// Swift's native implementation of ISO 8601 date decoding defaults to a format that doesn't include milliseconds, causing decoding errors because of Twitter's date format.
  /// This function returns a decoder which can decode Twitter's date formats, as well as converting keys from snake_case to camelCase.
  static internal func initializeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
      let container = try decoder.singleValueContainer()
      let dateStr = try container.decode(String.self)
      
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
      if let date = formatter.date(from: dateStr) {
        return date
      }
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
      if let date = formatter.date(from: dateStr) {
        return date
      }
      throw TwiftError.UnknownError()
    })
    
    return decoder
  }
  
  static internal func initializeEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    
    return encoder
  }
  
  /// Refreshes the OAuth 2.0 token, optionally forcing a refresh even if the token is still valid
  /// - Parameter onlyIfExpired: Set to false to force the token to refresh even if it hasn't yet expired.
  public func refreshOAuth2AccessToken(onlyIfExpired: Bool = true) async throws {
    guard case AuthenticationType.oauth2UserAuth(let oauthUser) = self.authenticationType,
          let refreshToken = oauthUser.refreshToken,
          let clientId = oauthUser.clientId else {
      throw TwiftError.WrongAuthenticationType(needs: .oauth2UserAuth)
    }
    
    // Return early if the token has not yet expired
    if onlyIfExpired && !oauthUser.expired {
      return
    }
    
    var refreshRequest = URLRequest(url: URL(string: "https://api.twitter.com/2/oauth2/token")!)
    
    refreshRequest.httpMethod = "POST"
    refreshRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let body = [
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "client_id": clientId
    ]
    
    let encodedBody = OAuthHelper.httpBody(forFormParameters: body)
    refreshRequest.httpBody = encodedBody
    
    let (data, _) = try await URLSession.shared.data(for: refreshRequest)
    
    var refreshedOAuthUser = try JSONDecoder().decode(OAuth2User.self, from: data)
    refreshedOAuthUser.clientId = clientId
    
    self.authenticationType = .oauth2UserAuth(refreshedOAuthUser)
  }
}
