import Foundation

public extension Twift {
  func volumeStream(fields: Set<Tweet.Fields> = [],
                    expansions: [Tweet.Expansions] = [],
                    backfillMinutes: Int? = nil
  ) async throws -> AsyncThrowingMapSequence<AsyncLineSequence<URLSession.AsyncBytes>, TwitterAPIDataAndIncludes<Tweet, Tweet.Includes>> {
    var queryItems = fieldsAndExpansions(for: Tweet.self, fields: fields, expansions: expansions)
    
    if let backfillMinutes = backfillMinutes {
      switch backfillMinutes {
      case 0...5:
        break
      default:
        throw TwiftError.RangeOutOfBoundsError(min: 0, max: 5, fieldName: "backfillMinutes", actual: backfillMinutes)
      }
      
      queryItems.append(URLQueryItem(name: "backfill_minutes", value: "\(backfillMinutes)"))
    }
    
    let url = getURL(for: .volumeStream, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    try signURLRequest(method: .GET, request: &request)
    
    return try await URLSession.shared.bytes(for: request).0.lines
      .map { line throws -> TwitterAPIDataAndIncludes<Tweet, Tweet.Includes> in
        guard let data = line.data(using: .utf8) else { throw TwiftError.UnknownError }
        return try self.decodeOrThrow(decodingType: TwitterAPIDataAndIncludes.self, data: data)
      }
  }
}
