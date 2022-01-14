import Foundation


public enum TwiftError: Error {
  case CallbackURLError
  case MissingCredentialsError
  case DecodingError(type: Any.Type, data: Data? = nil)
  case MalformedUserIDError(_ malformedId: String)
  case OAuthTokenError
  case UnknownError
  case RangeOutOfBoundsError(min: Int = 1, max: Int = 1000, fieldName: String, actual: Int)
  
  public var errorDescription: String {
    switch self {
    case .CallbackURLError:
      return "The provided callback URL is invalid"
    case .MissingCredentialsError:
      return "One of the required credential types (bearer token or client & user credentials) is missing from this Twift instance"
    case .DecodingError(let type, let data):
      return "There was an error decoding the data into the expected type (\(type.self): \(String(describing: data))"
    case .MalformedUserIDError(let malformedID):
      return "The user ID \(malformedID) is invalid; it should be an integer represented as a String"
    case .OAuthTokenError:
      return "Unable to obtain OAuth request token from Twitter. This usually happens is the callback URL is invalid or not allowed on the client application."
    case .UnknownError:
      return "Unknown Error"
    case .RangeOutOfBoundsError(let min, let max, let fieldName, let actual):
      return "Expected a value between \(min) and \(max) for field \"\(fieldName)\" but got \(actual)"
    }
  }
}

public struct TwitterAPIError: Codable, Error, Hashable {
  public let title: String
  public let detail: String
  public let type: URL
  public let includes: String?
  public let resourceId: String?
  public let resourceType: String?
  
  public var errorDescription: String {
    """
Error: \(title)
Details: \(detail)
More info: \(type.absoluteString)
"""
  }
}
