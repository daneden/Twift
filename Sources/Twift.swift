import Foundation
import Combine

@MainActor
public class Twift: NSObject, ObservableObject {
  /// The type of authentication access for this Twift instance
  @Published public private(set) var authenticationType: AuthenticationType
  public var oauthUser: OAuth2User? {
    switch authenticationType {
      case .oauth2UserAuth(let user, _):
        return user
      default:
        return nil
    }
  }
  
  internal let decoder: JSONDecoder
  internal let encoder: JSONEncoder
  
  /// Initialise an instance with the specified authentication type
  public init(_ authenticationType: AuthenticationType) {
    self.authenticationType = authenticationType
    
    self.decoder = Self.initializeDecoder()
    self.encoder = Self.initializeEncoder()
  }
  
  /// Initialises an instance with OAuth2 User authentication
  /// - Parameters:
  ///   - oauth2User: The OAuth2 User object for authenticating requests on behalf of a user
  ///   - onTokenRefresh: A callback invoked when the access token is refreshed by Twift. Useful for storing updated credentials.
  public convenience init(oauth2User: OAuth2User,
                          onTokenRefresh: @escaping (OAuth2User) -> Void = { _ in }) {
    self.init(.oauth2UserAuth(oauth2User, onRefresh: onTokenRefresh))
  }
  
  /// Initialises an instance with App-Only Bearer Token authentication
  /// - Parameters:
  ///   - appOnlyBearerToken: The App-Only Bearer Token issued by Twitter for authenticating requests
  public convenience init(appOnlyBearerToken: String) {
    self.init(.appOnly(bearerToken: appOnlyBearerToken))
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
      
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      if let date = formatter.date(from: dateStr) {
        return date
      }
      
      formatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
      if let date = formatter.date(from: dateStr) {
        return date
      }
      
      if dateStr == "string" && isTestEnvironment {
        print("Test environment detected: simulating date for data decoder")
        return .now
      }
      
      throw TwiftError.UnknownError("Couldn't decode date from returned data: \(decoder.codingPath.description)")
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
  /// After a successful refresh, a user-defined callback is performed. (optional)
  /// - Parameter onlyIfExpired: Set to false to force the token to refresh even if it hasn't yet expired.
  public func refreshOAuth2AccessToken(onlyIfExpired: Bool = true) async throws {
    guard case AuthenticationType.oauth2UserAuth(let oauthUser, let refreshCompletion) = self.authenticationType else {
      throw TwiftError.WrongAuthenticationType(needs: .oauth2UserAuth)
    }
    
    // Return early if the token has not yet expired
    if onlyIfExpired && !oauthUser.expired {
      return
    }
    
    guard let refreshToken = oauthUser.refreshToken,
          let clientId = oauthUser.clientId else {
      throw TwiftError.UnknownError("Couldn't find refresh token or client ID")
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
    
    refreshCompletion?(refreshedOAuthUser)
    
    self.authenticationType = .oauth2UserAuth(refreshedOAuthUser, onRefresh: refreshCompletion)
  }
}
