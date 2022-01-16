import Foundation

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
  public struct Option: Codable {
    public let position: Int
    public let votes: Int
    public let label: String
  }
  
  public enum VotingStatus: String, RawRepresentable, Codable {
    case closed
    case open
  }
}

extension Poll: Fielded {
  public enum Fields: String, Codable, CaseIterable {
    case durationMinutes = "duration_minutes"
    case endDatetime = "end_datetime"
    case votingStatus = "voting_status"
  }
}
