import Foundation

public extension Twift {
  /// Causes the user ID to Like the target Tweet.
  ///
  /// Equivalent to `POST /2/users/:user_id/likes`
  /// - Parameters:
  ///   - tweetId: The ID of the Tweet that you would like the `userId` to Like.
  ///   - userId: The user ID who you are liking a Tweet on behalf of. It must match your own user ID or that of an authenticating user.
  /// - Returns: A response object containing a ``LikeResponse``
  func likeTweet(_ tweetId: Tweet.ID, userId: User.ID) async throws -> TwitterAPIData<LikeResponse> {
    let body = ["tweet_id": tweetId]
    let encodedBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    return try await call(route: .userLikes(userId),
                          method: .POST,
                          body: encodedBody,
                          expectedReturnType: TwitterAPIData.self)
  }
}

public struct LikeResponse: Codable {
  /// Indicates whether the user likes the specified Tweet as a result of this request.
  let liked: Bool
}
