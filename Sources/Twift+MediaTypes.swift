import Foundation

public struct Media: Codable, Identifiable {
  public typealias ID = String
  public let mediaKey: ID
  public var id: ID { mediaKey }
  public let type: MediaType
  public let durationMs: Int?
  public let height: Int?
  public let nonPublicMetrics: Metrics?
  public let organicMetrics: Metrics?
  public let promotedMetrics: Metrics?
  public let publicMetrics: PublicMetrics?
  public let width: Int?
  public let altText: String?
}

public enum MediaType: String, Codable, RawRepresentable {
  case animatedGif, video, photo
}

extension Media {
  public struct Metrics: Codable {
    public let playback0Count: Int
    public let playback100Count: Int
    public let playback25Count: Int
    public let playback50Count: Int
    public let playback75Count: Int
    public let viewCount: Int?
  }
  
  public struct PublicMetrics: Codable {
    public let viewCount: Int
  }
}
