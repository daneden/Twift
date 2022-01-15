import Foundation

/// A response object containing information relating to a block status.
public struct BlockResponse: Codable {
  /// Whether or not the source user is blocking the target user.
  public let blocking: Bool
}
