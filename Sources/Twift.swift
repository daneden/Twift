import Foundation
import Combine
import AuthenticationServices

@MainActor
public class Twift: NSObject, ObservableObject {
  internal let clientCredentials: OAuthToken
  public var userCredentials: OAuthToken?
  internal let decoder: JSONDecoder
  
  public init(clientCredentials: OAuthToken, userCredentials: OAuthToken? = nil) {
    self.clientCredentials = clientCredentials
    self.userCredentials = userCredentials
    
    self.decoder = JSONDecoder()
    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
  }
  
  /// Signs a URL request with the necessary authorization headers for a given user
  /// - Parameters:
  ///   - urlRequest: The URL request to sign
  ///   - userID: The user's ID
  ///   - method: HTTP method for the request
  ///   - body: The body for the request
  ///   - contentType: The content type for the request
  /// - Returns: The signed URL request
  func signRequest(_ urlRequest: inout URLRequest,
                   method: HTTPMethod = .GET,
                   body: Data? = nil,
                   contentType: String? = nil
  ) throws {
    guard let userCredentials = userCredentials else {
      throw TwiftError.MissingCredentialsError
    }
    
    urlRequest.oAuthSign(
      method: method.rawValue,
      body: body,
      contentType: contentType,
      consumerCredentials: (key: clientCredentials.key, secret: clientCredentials.secret),
      userCredentials: (key: userCredentials.key, secret: userCredentials.secret)
    )
  }
  
  public typealias RequestAuthenticationCompletion = (userCredentials: OAuthToken?, error: Error?)
  /// Request user credentials by presenting Twitter's web-based authentication flow
  /// - Parameters:
  ///   - presentationContextProvider: Optional presentation context provider. When not provided, this function will handle the presentation context itself.
  ///   - callbackURL: The callback URL as configured in your Twitter application settings
  ///   - completion: A callback that allows the caller to handle subsequent user credentials or errors. Callers are responsible for storing the user credentials for later use.
  public func requestUserCredentials(
    presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil,
    callbackURL: URL,
    with completion: @escaping (RequestAuthenticationCompletion) -> Void
  ) async {
    guard let callbackScheme = callbackURL.scheme else {
      return completion((userCredentials: nil, error: TwiftError.CallbackURLError))
    }
    
    // MARK:  Step one: Obtain a request token
    var stepOneRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
    
    stepOneRequest.oAuthSign(
      method: "POST",
      urlFormParameters: ["oauth_callback" : callbackScheme + "://"],
      consumerCredentials: (key: clientCredentials.key, secret: clientCredentials.secret)
    )
    
    var oauthToken: String = ""
    
    do {
      let (requestTokenData, _) = try await URLSession.shared.data(for: stepOneRequest)
      
      guard let response = String(data: requestTokenData, encoding: .utf8)?.urlQueryStringParameters,
            let token = response["oauth_token"] else {
              return completion((
                userCredentials: nil,
                error: TwiftError.DecodingError(type: String.self, data: requestTokenData))
              )
            }
      
      oauthToken = token
    } catch {
      return completion((userCredentials: nil, error: error))
    }
    
    // MARK:  Step two: Redirecting the user
    let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(oauthToken)")!
    
    let authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "https") { (url, error) in
      if let error = error {
        print(error.localizedDescription)
      } else if let url = url {
        guard let queryItems = url.query?.urlQueryStringParameters,
              let oauthToken = queryItems["oauth_token"],
              let oauthVerifier = queryItems["oauth_verifier"] else {
                return
              }
        
        // MARK:  Step three: Converting the request token into an access token
        Task {
          var stepThreeRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/access_token?oauth_verifier=\(oauthVerifier)")!)
          
          stepThreeRequest.oAuthSign(
            method: "POST",
            urlFormParameters: ["oauth_token" : oauthToken],
            consumerCredentials: (key: self.clientCredentials.key, secret: self.clientCredentials.secret)
          )
          
          let (data, _) = try await URLSession.shared.data(for: stepThreeRequest)
          
          guard let response = String(data: data, encoding: .utf8)?.urlQueryStringParameters,
                let encoded = try? JSONEncoder().encode(response) else {
                  print("Failed to decode step three response: \(data.description)")
                  return
                }
          
          do {
            let userCredentials = try JSONDecoder().decode(OAuthToken.self, from: encoded)
            completion((userCredentials: userCredentials, error: nil))
          } catch {
            print(error)
          }
        }
      }
    }
    
    authSession.presentationContextProvider = presentationContextProvider ?? self
    authSession.start()
  }
}

extension String {
  var urlEncoded: String {
    var charset: CharacterSet = .urlQueryAllowed
    charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
    return self.addingPercentEncoding(withAllowedCharacters: charset)!
  }
}

extension String {
  var urlQueryStringParameters: Dictionary<String, String> {
    // breaks apart query string into a dictionary of values
    var params = [String: String]()
    let items = self.split(separator: "&")
    for item in items {
      let combo = item.split(separator: "=")
      if combo.count == 2 {
        let key = "\(combo[0])"
        let val = "\(combo[1])"
        params[key] = val
      }
    }
    return params
  }
}

extension Twift: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}

struct TwitterAPIResponse<T: Codable>: Codable {
  var data: T?
  var title: String?
  var detail: String?
  var type: URL?
}

struct TwitterAPIError: Error {
  var title: String?
  var detail: String?
  var type: URL?
}
