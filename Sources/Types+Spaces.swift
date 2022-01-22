import Foundation

/// Spaces allow expression and interaction via live audio conversations. The Space data dictionary contains relevant metadata about a Space; all the details are updated in real time.
public struct Space: Codable, Identifiable {
  public typealias ID = String
  
  /// The unique identifier of the requested Space.
  public let id: ID
  
  /// Indicates if the Space has started or will start in the future, or if it has ended.
  public let state: String
  
  /// Creation time of this Space.
  public let createdAt: Date?
  
  /// Time when the Space was ended. Only available for ended Spaces.
  public let endedAt: Date?
  
  /// The unique identifier of the users who are hosting this Space.
  public let hostIds: [User.ID]?
  
  /// Language of the Space, if detected by Twitter. Returned as a BCP47 language tag.
  public let lang: String?
  
  /// Indicates is this is a ticketed Space.
  public let isTicketed: Bool?
  
  /// The list of user IDs that were invited to join as speakers. Usually, users in this list are invited to speak via the Invite user option.
  public let invitedUserIds: [User.ID]?
  
  /// The current number of users in the Space, including Hosts and Speakers.
  public let participantCount: Int?
  
  /// Indicates the start time of a scheduled Space, as set by the creator of the Space. This field is returned only if the Space has been scheduled; in other words, if the field is returned, it means the Space is a scheduled Space.
  public let scheduledStart: Date?
  
  /// The list of users who were speaking at any point during the Space. This list contains all the users in `invitedUserIds` in addition to any user who requested to speak and was allowed via the Add speaker option.
  public let speakerIds: [User.ID]?
  
  /// Indicates the actual start time of a Space.
  public let startedAt: Date?
  
  /// The title of the Space as specified by the creator.
  public let title: String?
  
  /// A list of IDs of the topics selected by the creator of the Space.
  public let topicIds: [String]?
  
  /// Specifies the date and time of the last update to any of the Space's metadata, such as its title or scheduled time.
  public let updatedAt: Date?
}

extension Space: Fielded {
  typealias Field = PartialKeyPath<Self>
  
  static internal func fieldName(field: PartialKeyPath<Space>) -> String? {
    switch field {
    case \.createdAt: return "created_at"
    case \.endedAt: return "ended_at"
    case \.hostIds: return "host_ids"
    case \.lang: return "lang"
    case \.isTicketed: return "is_ticketed"
    case \.invitedUserIds: return "invited_user_ids"
    case \.participantCount: return "participant_count"
    case \.scheduledStart: return "scheduled_start"
    case \.speakerIds: return "speaker_ids"
    case \.startedAt: return "started_at"
    case \.title: return "title"
    case \.topicIds: return "topic_ids"
    case \.updatedAt: return "updated_at"
    default: return nil
    }
  }
  
  static internal var fieldParameterName = "space.fields"
}

extension Space: Expandable {
  public enum Expansions: Expansion {
    case hostIds(_ fields: Set<User.Field>)
    case creatorId(_ fields: Set<User.Field>)
    case speakerIds(_ fields: Set<User.Field>)
    case mentionedUserIds(_ fields: Set<User.Field>)
    
    internal var rawValue: String {
      switch self {
      case .hostIds: return "host_ids"
      case .creatorId: return "creator_id"
      case .speakerIds: return "speaker_ids"
      case .mentionedUserIds: return "mentioned_user_ids"
      }
    }
    
    internal var fields: URLQueryItem? {
      switch self {
      case .hostIds(let fields):
        if !fields.isEmpty { return URLQueryItem(name: User.fieldParameterName, value: fields.compactMap { User.fieldName(field: $0) }.joined(separator: ",")) }
      case .creatorId(let fields):
        if !fields.isEmpty { return URLQueryItem(name: User.fieldParameterName, value: fields.compactMap { User.fieldName(field: $0) }.joined(separator: ",")) }
      case .speakerIds(let fields):
        if !fields.isEmpty { return URLQueryItem(name: User.fieldParameterName, value: fields.compactMap { User.fieldName(field: $0) }.joined(separator: ",")) }
      case .mentionedUserIds(let fields):
        if !fields.isEmpty { return URLQueryItem(name: User.fieldParameterName, value: fields.compactMap { User.fieldName(field: $0) }.joined(separator: ",")) }
      }
      
      return nil
    }
  }
}
