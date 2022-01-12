import Foundation


public enum TwiftError: Error {
  case CallbackURLError
  case MissingCredentialsError
  case DecodingError(type: Any.Type, data: Data)
  case MalformedUserIDError(_ malformedId: String)
  case UserNotFoundError(_ userId: UserID)
  
  public var description: String {
    switch self {
    case .CallbackURLError:
      return "The provided callback URL is invalid"
    case .MissingCredentialsError:
      return "This API method requires user credentials, but no user credentials were found in this Twift instance"
    case .DecodingError(let type, let data):
      return "There was an error decoding the data into the expected type (\(type.self): \(data.description)"
    case .MalformedUserIDError(let malformedID):
      return "The user ID \(malformedID) is invalid; it should be an integer represented as a String"
    case .UserNotFoundError(let userId):
      return "No user with id \(userId) found"
    }
  }
  
  public var localizedDescription: String {
    return description
  }
}

