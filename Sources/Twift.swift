import Foundation
import Combine

@MainActor
public class Twift: NSObject, ObservableObject {
  /// The type of authentication access for this Twift instance
  public let authenticationType: AuthenticationType
  
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
}
