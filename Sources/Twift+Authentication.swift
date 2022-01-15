import Foundation
import AuthenticationServices

extension Twift {
  // MARK: Authentication methods
  
  public typealias RequestAuthenticationCompletion = (userCredentials: OAuthCredentials?, error: Error?)
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
    guard let clientCredentials = clientCredentials else {
      return completion((userCredentials: nil, error: TwiftError.MissingCredentialsError))
    }
    
    // MARK:  Step one: Obtain a request token
    var stepOneRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
    
    stepOneRequest.oAuthSign(
      method: "POST",
      urlFormParameters: ["oauth_callback" : callbackURL.absoluteString],
      consumerCredentials: (key: clientCredentials.key, secret: clientCredentials.secret)
    )
    
    var oauthToken: String = ""
    
    do {
      let (requestTokenData, _) = try await URLSession.shared.data(for: stepOneRequest)
      
      guard let response = String(data: requestTokenData, encoding: .utf8)?.urlQueryStringParameters,
            let token = response["oauth_token"] else {
              return completion((
                userCredentials: nil,
                error: TwiftError.OAuthTokenError
              ))
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
            consumerCredentials: (key: clientCredentials.key, secret: clientCredentials.secret)
          )
          
          let (data, _) = try await URLSession.shared.data(for: stepThreeRequest)
          
          guard let response = String(data: data, encoding: .utf8)?.urlQueryStringParameters,
                let encoded = try? JSONEncoder().encode(response) else {
                  print("Failed to decode step three response: \(data.description)")
                  return
                }
          
          do {
            let userCredentials = try JSONDecoder().decode(OAuthCredentials.self, from: encoded)
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

extension Twift: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}
