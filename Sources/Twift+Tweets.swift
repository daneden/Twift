import Foundation

extension Twift {
  public func getTweet(_ tweetId: Tweet.ID,
                       fields: Fields? = nil,
                       expansions: [Tweet.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<Tweet, Tweet.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .tweet(tweetId),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  public func getTweets(_ tweetIds: [Tweet.ID],
                        fields: Fields? = nil,
                        expansions: [Tweet.Expansions] = []
  ) async throws -> TwitterAPIDataAndIncludes<Tweet, Tweet.Includes> {
    return try await call(fields: fields,
                          expansions: expansions.map { $0.rawValue },
                          route: .tweets(tweetIds),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
}
