import Foundation

public struct Poll: Codable, Identifiable {
  public typealias ID = String
  public let id: ID
  public let options: [Option]
  public let durationMinutes: Int?
  public let endDatetime: Date?
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

extension Poll {
  public enum Fields: String, Codable, CaseIterable {
    case durationMinutes = "duration_minutes"
    case endDatetime = "end_datetime"
    case votingStatus = "voting_status"
  }
}
