import Foundation

/// Media refers to any image, GIF, or video attached to a Tweet. The media object is not a primary object on any endpoint, but can be found and expanded in the Tweet object. 
public struct Media: Codable, Identifiable {
  public typealias ID = String
  
  /// Unique identifier of the expanded media content.
  public let mediaKey: ID
  public var id: ID { mediaKey }
  
  /// Type of content (animated_gif, photo, video).
  public let type: MediaType
  
  /// Available when type is video. Duration in milliseconds of the video.
  public let durationMs: Int?
  
  /// Height of this content in pixels.
  public let height: Int?
  
  /// Non-public engagement metrics for the media content at the time of the request.
  /// Requires user context authentication.
  public let nonPublicMetrics: Metrics?
  
  /// Engagement metrics for the media content, tracked in an organic context, at the time of the request.
  /// Requires user context authentication.
  public let organicMetrics: Metrics?
  
  /// Engagement metrics for the media content, tracked in a promoted context, at the time of the request.
  /// Requires user context authentication.
  public let promotedMetrics: Metrics?
  
  /// Public engagement metrics for the media content at the time of the request.
  public let publicMetrics: PublicMetrics?
  
  /// Width of this content in pixels.
  public let width: Int?
  
  /// A description of an image to enable and support accessibility. Can be up to 1000 characters long. Alt text can only be added to images at the moment.
  public let altText: String?
  
  /// URL to the static placeholder preview of this content.
  public let previewImageUrl: URL?
  public let url: URL?
}

public enum MediaType: String, Codable, RawRepresentable {
  case animatedGif
  case video
  case photo
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

extension Media: Fielded {
  public enum Fields: String, Codable, CaseIterable {
    case height
    case width
    case altText = "alt_text"
    case previewImageUrl = "preview_image_url"
    case nonPublicMetrics = "non_public_metrics"
    case publicMetrics = "public_metrics"
    case durationMs = "duration_ms"
    case url
    case organicMetrics = "organic_metrics"
    case promotedMetrics = "promoted_metrics"
  }
}
