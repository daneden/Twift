import Foundation

@available(macOS 12.0, *)
extension Twift {
  enum TwiftError: Error {
    case CallbackURLError
    case MissingCredentialsError
    case DecodingError(type: Any.Type, data: Data)
  }
}
