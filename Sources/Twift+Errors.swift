import Foundation


public enum TwiftError: Error {
  case CallbackURLError
  case MissingCredentialsError
  case DecodingError(type: Any.Type, data: Data? = nil)
  case MalformedUserIDError(_ malformedId: String)
  case UserNotFoundError(_ userId: UserID)
  case OAuthTokenError
  case UnknownError
  
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
    case .UserNotFoundError(let userId):
      return "No user with id \(userId) found"
    case .OAuthTokenError:
      return "Unable to obtain OAuth request token from Twitter. This usually happens is the callback URL is invalid or not allowed on the client application."
    case .UnknownError:
      return "Unknown Error"
    }
  }
}

public struct TwitterAPIError: Codable, Error {
  public let title: String
  public let detail: String
  public let type: URL
  
  public var description: String {
    """
Error: \(title)
Details: \(detail)
More info: \(type.absoluteString)
"""
  }
  
  public var localizedDescription: String {
    description
  }
}

public struct TwitterResourceError: Codable, Error {
  public let detail: String
  public let resourceId: String
  public let resourceType: String
  public let title: String
  public let type: URL
  public let section: String
}
