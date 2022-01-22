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
    
    /// App-only authentication
    case appOnly(bearerToken: String)
  }
  
  /// A convenience enum for representing ``AuthenticationType`` without associated values in auth-related errors
  public enum AuthenticationTypeRepresentation: String {
    /// A value representing ``AuthenticationType.userAccessTokens(_, _)``
    case userAccessTokens
    
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
        
        let authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "https") { (url, error) in
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
