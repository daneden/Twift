import Foundation
import AuthenticationServices

extension Twift {
  // MARK: Authentication methods
}

extension Twift {
  /// The available authentication types for initializing new `Twift` client instances
  public enum AuthenticationType {
    /// OAuth 1.0a User Access Token authentication.
    ///
    /// User credentials can be obtained by calling ``Twift.Authentication().requestUserCredentials()``
    case userAccessTokens(clientCredentials: OAuthCredentials,
                          userCredentials: OAuthCredentials)
    
    
    /// OAuth 2.0 User Context authentication.
    ///
    /// When this authentication method is used, the `oauth2User` access token may be automatically refreshed by the client if it has expired.
    case oauth2UserContext(oauth2User: OAuth2User)
    
    /// App-only authentication
    case appOnly(bearerToken: String)
  }
  
  /// A convenience enum for representing ``AuthenticationType`` without associated values in auth-related errors
  public enum AuthenticationTypeRepresentation: String {
    /// A value representing ``AuthenticationType.userAccessTokens(_, _)``
    case userAccessTokens
    
    /// A value representing ``AuthenticationType.oauth2UserContext(_)``
    case oauth2UserContext
    
    /// A value representing ``AuthenticationType.appOnly(_)``
    case appOnly
  }
  
  /// A convenience class for acquiring user access token
  public class Authentication: NSObject, ASWebAuthenticationPresentationContextProviding {
    /// Request user credentials by presenting Twitter's web-based authentication flow
    /// - Parameters:
    ///   - presentationContextProvider: Optional presentation context provider. When not provided, this function will handle the presentation context itself.
    ///   - callbackURL: The callback URL as configured in your Twitter application settings
    ///   - completion: A callback that allows the caller to handle subsequent user credentials or errors. Callers are responsible for storing the user credentials for later use.
    public func requestUserCredentials(
      clientCredentials: OAuthCredentials,
      callbackURL: URL,
      presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil,
      with completion: @escaping ((userCredentials: OAuthCredentials?, error: Error?)) -> Void
    ) {
      // MARK:  Step one: Obtain a request token
      var stepOneRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
      
      stepOneRequest.oAuthSign(
        method: "POST",
        urlFormParameters: ["oauth_callback" : callbackURL.absoluteString],
        consumerCredentials: clientCredentials
      )
      
      var oauthToken: String = ""
      
      URLSession.shared.dataTask(with: stepOneRequest) { (requestTokenData, _, error) in
        guard let requestTokenData = requestTokenData,
              let response = String(data: requestTokenData, encoding: .utf8)?.urlQueryStringParameters,
              let token = response["oauth_token"] else {
                return completion((
                  userCredentials: nil,
                  error: TwiftError.OAuthTokenError
                ))
              }
        
        oauthToken = token
        
        // MARK:  Step two: Redirecting the user
        let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(oauthToken)")!

        guard let callbackURLScheme = callbackURL.scheme else {
          preconditionFailure("Malformed callback URL. Scheme is required.")
        }
        
        let authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { (url, error) in
          if let error = error {
            return completion((nil, error))
          }
          
          if let url = url {
            guard let queryItems = url.query?.urlQueryStringParameters,
                  let oauthToken = queryItems["oauth_token"],
                  let oauthVerifier = queryItems["oauth_verifier"] else {
                    return
                  }
            
            // MARK:  Step three: Converting the request token into an access token
            
            var stepThreeRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/access_token?oauth_verifier=\(oauthVerifier)")!)
            
            stepThreeRequest.oAuthSign(
              method: "POST",
              urlFormParameters: ["oauth_token" : oauthToken],
              consumerCredentials: clientCredentials
            )
            
            URLSession.shared.dataTask(with: stepThreeRequest) { (data, _, error) in
              guard let data = data,
                    let response = String(data: data, encoding: .utf8)?.urlQueryStringParameters,
                    let encoded = try? JSONEncoder().encode(response) else {
                      return completion((nil, error))
                    }
              
              do {
                let userCredentials = try JSONDecoder().decode(OAuthCredentials.self, from: encoded)
                completion((userCredentials: userCredentials, error: nil))
              } catch {
                print(error)
              }
            }.resume()
          }
        }
        
        DispatchQueue.main.async {
          authSession.presentationContextProvider = presentationContextProvider ?? self
          authSession.start()
        }
        
      }.resume()
      
    }
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
      return ASPresentationAnchor()
    }
  }
}

extension Twift.Authentication {
  public func authorizeUser(clientId: String,
                            redirectUri: URL,
                            scope: Set<OAuth2Scope>,
                            presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
  ) async -> (OAuth2User?, Error?) {
    let state = UUID().uuidString
    
    let authUrlQueryItems: [URLQueryItem] = [
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "client_id", value: clientId),
      URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
      URLQueryItem(name: "scope", value: scope.map(\.rawValue).joined(separator: " ")),
      URLQueryItem(name: "state", value: state),
      URLQueryItem(name: "code_challenge", value: "challenge"),
      URLQueryItem(name: "code_challenge_method", value: "plain"),
    ]
    
    var authUrl = URLComponents()
    authUrl.scheme = "https"
    authUrl.host = "twitter.com"
    authUrl.path = "/i/oauth2/authorize"
    authUrl.queryItems = authUrlQueryItems
    
    let (returnedUrl, error): (URL?, Error?) = await withCheckedContinuation { continuation in
      guard let authUrl = authUrl.url else {
        return continuation.resume(returning: (nil, TwiftError.UnknownError(nil)))
      }

      let authSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: redirectUri.scheme) { (url, error) in
        return continuation.resume(returning: (url, error))
      }
      
      authSession.presentationContextProvider = presentationContextProvider ?? self
      authSession.start()
    }
    
    if let error = error {
      print(error.localizedDescription)
      return (nil, error)
    }
    
    guard let returnedUrl = returnedUrl else {
      return (nil, TwiftError.UnknownError("No returned OAuth URL"))
    }
    
    let returnedUrlComponents = URLComponents(string: returnedUrl.absoluteString)
    
    let returnedState = returnedUrlComponents?.queryItems?.first(where: { $0.name == "state" })?.value
    guard let returnedState = returnedState,
          returnedState == state else {
      return (nil, TwiftError.UnknownError("Bad state returned from OAuth flow"))
    }

    let returnedCode = returnedUrlComponents?.queryItems?.first(where: { $0.name == "code" })?.value
    guard let returnedCode = returnedCode else {
      return (nil, TwiftError.UnknownError("No code returned"))
    }
    
    var codeRequest = URLRequest(url: URL(string: "https://api.twitter.com/2/oauth2/token")!)
    let body = [
      "code": returnedCode,
      "grant_type": "authorization_code",
      "client_id": clientId,
      "redirect_uri": redirectUri.absoluteString,
      "code_verifier": "challenge"
    ]
    
    let encodedBody = try? JSONSerialization.data(withJSONObject: body)
    
    codeRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    codeRequest.httpMethod = "POST"
    codeRequest.httpBody = encodedBody
    
    do {
      let (data, _) = try await URLSession.shared.data(for: codeRequest)
      
      print(String(data: data, encoding: .utf8))
    } catch {
      print(error.localizedDescription)
    }
    
    return (nil, nil)
  }
}

public struct OAuth2User {
  public var clientId: String
  public var userId: String?
  public var accessToken: String
  public var refreshToken: String?
  public var expiresAt: Date
  public var scope: [OAuth2Scope]
  
  public var expired: Bool {
    expiresAt < .now
  }
}

public enum OAuth2Scope: String, CaseIterable, RawRepresentable {
  /// All the Tweets you can view, including Tweets from protected accounts.
  case tweetRead = "tweet.read"
  
  /// Tweet and Retweet for you.
  case tweetWrite = "tweet.write"
  
  /// Hide and unhide replies to your Tweets.
  case tweetModerateWrite = "tweet.moderate.write"
  
  /// Any account you can view, including protected accounts.
  case usersRead = "users.read"
  
  /// People who follow you and people who you follow.
  case followsRead = "follows.read"
  
  /// Follow and unfollow people for you.
  case followsWrite = "follows.write"
  
  /// Stay connected to your account until you revoke access.
  case offlineAccess = "offline.access"
  
  /// All the Spaces you can view.
  case spaceRead = "space.read"
  
  /// Accounts you’ve muted.
  case muteRead = "mute.read"
  
  /// Mute and unmute accounts for you.
  case muteWrite = "mute.write"
  
  /// Tweets you’ve liked and likes you can view.
  case likeRead = "like.read"
  
  /// Like and un-like Tweets for you.
  case likeWrite = "like.write"
  
  /// Lists, list members, and list followers of lists you’ve created or are a member of, including private lists.
  case listRead = "list.read"
  
  /// Create and manage Lists for you.
  case listWrite = "list.write"
  
  /// Accounts you’ve blocked.
  case blockRead = "block.read"
  
  /// Block and unblock accounts for you.
  case blockWrite = "block.write"
  
  /// Get Bookmarked Tweets from an authenticated user.
  case bookmarkRead = "bookmark.read"
  
  /// Bookmark and remove Bookmarks from Tweets
  case bookmarkWrite = "bookmark.write"
  
  /// All write-permission scopes.
  static var allWriteScopes: Set<OAuth2Scope> {
    [.likeWrite, .listWrite, .muteWrite, .blockWrite, .tweetWrite, .followsWrite, .bookmarkWrite, .tweetModerateWrite]
  }
  
  /// All read-permission scopes.
  static var allReadScopes: Set<OAuth2Scope> {
    [.likeRead, .listRead, .muteRead, .blockRead, .spaceRead, .tweetRead, .usersRead, .followsRead, .bookmarkRead]
  }
}
