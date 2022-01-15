import Foundation
import Combine

@MainActor
public class Twift: NSObject, ObservableObject {
  internal let clientCredentials: OAuthCredentials?
  @Published public var userCredentials: OAuthCredentials?
  @Published public var bearerToken: String?
  internal let decoder: JSONDecoder
  
  public init(clientCredentials: OAuthCredentials, userCredentials: OAuthCredentials? = nil) {
    self.clientCredentials = clientCredentials
    self.userCredentials = userCredentials
    
    self.decoder = Self.initializeDecoder()
  }
  
  public init(bearerToken: String) {
    self.clientCredentials = nil
    self.bearerToken = bearerToken
    
    self.decoder = Self.initializeDecoder()
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
      throw TwiftError.UnknownError
    })
    
    return decoder
  }
}
