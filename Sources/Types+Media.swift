import Foundation

/// Media refers to any image, GIF, or video attached to a Tweet. The media object is not a primary object on any endpoint, but can be found and expanded in the Tweet object. 
public struct Media: Codable, Identifiable {
  public typealias ID = String
  
  /// Unique identifier of the expanded media content.
  public let mediaKey: ID
  
  /// A convenience accessor for the `mediaKey` property mapped to the more standard `id` key path
  public var id: ID { mediaKey }
  
  /// Type of media
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
  
  /// URL to the media content
  public let url: URL?
  
  /// Each media object may have multiple display or playback variants, with different resolutions or formats
  public let variants: [Variant]?
}

public enum MediaType: String, Codable, RawRepresentable {
  /// Animated .gif media type
  case animatedGif = "animated_gif"
  
  /// Video media type
  case video
  
  /// Photo media type
  case photo
  
  #if DEBUG
  /// Used exclusively for the test suite
  case string
  #endif
}

extension Media {
  public struct Metrics: Codable {
    /// The number of viewers who watched beyond 0% of the video duration
    public let playback0Count: Int
    
    /// The number of viewers who watched 100% of the video duration
    public let playback100Count: Int
    
    /// The number of viewers who watched beyond 25% of the video duration
    public let playback25Count: Int
    
    /// The number of viewers who watched beyond 50% of the video duration
    public let playback50Count: Int
    
    /// The number of viewers who watched beyond 75% of the video duration
    public let playback75Count: Int
    public let viewCount: Int?
  }
  
  public struct PublicMetrics: Codable {
    /// The number of views the media has received
    public let viewCount: Int
  }
  
  public struct Variant: Codable {
    /// Bitrate of the media resource
    public var bitRate: Int?
    
    /// Type of media
    public var contentType: String
    
    /// URL to the media content
    public var url: String
  }
}

extension Media: Fielded {
  /// Additional fields that can be requested on the ``Media`` object
  public typealias Field = PartialKeyPath<Self>
  
  static internal func fieldName(field: PartialKeyPath<Media>) -> String? {
    switch field {
    case \.height: return "height"
    case \.width: return "width"
    case \.altText: return "alt_text"
    case \.previewImageUrl: return "preview_image_url"
    case \.nonPublicMetrics: return "non_public_metrics"
    case \.publicMetrics: return "public_metrics"
    case \.durationMs: return "duration_ms"
    case \.url: return "url"
    case \.organicMetrics: return "organic_metrics"
    case \.promotedMetrics: return "promoted_metrics"
    case \.variants: return "variants"
    default: return nil
    }
  }
  
  static internal var fieldParameterName = "media.fields"
}
