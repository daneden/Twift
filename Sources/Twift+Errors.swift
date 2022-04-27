import Foundation

// I'm not sure I should actually be typing this as `LocalizedError` but I can't get `description` to render any other way
/// The error types relating to Twift instances and methods.
public enum TwiftError: Error {
  /// This error is thrown when there is an attempt to make a request without the right credentials (usually either a bearer token or client & user credentials)
  case WrongAuthenticationType(needs: Twift.AuthenticationTypeRepresentation)
  
  /// This error is thrown when there was a problem obtaining an OAuth request token from Twitter. This usually happens if the callback URL is invalid or not allowed on the client application.
  case OAuthTokenError
  
  /// This error is thrown only when no other error type adequately matches the encountered problem.
  case UnknownError(_ context: Any? = nil)
  
  /// This error is thrown when the called function expected an integer within a specified range but was passed a value outside that range.
  case RangeOutOfBoundsError(min: Int = 1, max: Int = 1000, fieldName: String, actual: Int)
}

extension TwiftError: LocalizedError {
  /// The human-readable description for the error
  public var errorDescription: String? {
    switch self {
    case .WrongAuthenticationType(let authType):
      return "This method can only be called with the `.\(authType.rawValue)` client type."
    case .OAuthTokenError:
      return "Unable to obtain OAuth request token from Twitter. This usually happens if the callback URL is invalid or not allowed on the client application."
    case .UnknownError(let details):
      if let details = details {
        return "Unknown Error: \(details)"
      }
      return "Unknown Error: \(details.debugDescription)"
    case .RangeOutOfBoundsError(let min, let max, let fieldName, let actual):
      return "Expected a value between \(min) and \(max) for field \"\(fieldName)\" but got \(actual)"
    }
  }
}

/// An error returned from the Twitter API
public struct TwitterAPIError: Codable, Hashable {
  /// The summary of the encountered error
  public let title: String
  
  /// The details for the encountered error
  public let detail: String
  
  /// A URL for developers to learn more about the kind of encountered error
  public let type: URL
  
  /// The unique ID for the resource (if any) where the error originated
  public let resourceId: String?
  
  /// The resource type for the resource (if any) where the error originated
  public let resourceType: String?
  
  public let errors: [ErrorDetail]?
}

public struct ErrorDetail: Codable, Hashable {
  public let message: String?
}

extension TwitterAPIError: LocalizedError {
  /// The human-readable description for the error
  public var errorDescription: String? {
    """
Error: \(title)
Details: \(detail)
More info: \(type.absoluteString)
"""
  }
}
