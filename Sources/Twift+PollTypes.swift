import Foundation

/// A poll included in a Tweet is not a primary object on any endpoint, but can be found and expanded in the Tweet object.
public struct Poll: Codable, Identifiable {
  public typealias ID = String
  
  /// Unique identifier of the expanded poll.
  public let id: ID
  
  /// Contains objects describing each choice in the referenced poll.
  public let options: [Option]
  
  /// Specifies the total duration of this poll.
  public let durationMinutes: Int?
  
  /// Specifies the end date and time for this poll.
  public let endDatetime: Date?
  
  /// Indicates if this poll is still active and can receive votes, or if the voting is now closed.
  public let votingStatus: VotingStatus?
}


extension Poll {
  /// A single option in a Tweet poll
  public struct Option: Codable {
    /// The (1-based) index of this option as displayed in the poll
    public let position: Int
    
    /// The number of votes received for this poll option
    public let votes: Int
    
    /// The UTF-8 string label for this poll option
    public let label: String
  }
  
  /// The voting status for the associated poll
  public enum VotingStatus: String, RawRepresentable, Codable {
    /// A closed voting status, indicating no more votes can be submitted
    case closed
    
    /// An open voting status, indicating the poll can continue to receive votes until the `endDateTime`
    case open
  }
}

extension Poll: Fielded {
  /// Additional fields that can be requested on Poll objects
  public enum Fields: String, Codable, CaseIterable, Field {
    case durationMinutes = "duration_minutes"
    case endDatetime = "end_datetime"
    case votingStatus = "voting_status"
    
    static let parameterName = "poll.fields"
  }
}
