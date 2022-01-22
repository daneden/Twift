import Foundation

/// An object containing data relating to the creation and deletion of filtered stream rules
public struct FilteredStreamRuleMeta: Codable {
  /// The datetime stamp for when this data was sent
  public let sent: Date
  public let summary: Summary?
  
  public struct Summary: Codable {
    /// The number of filtered stream rules created as a result of this request
    public let created: Int?
    
    /// The number of filtered stream rules not created as a result of this request
    public let notCreated: Int?
    
    /// The number of filtered stream rules deleted as a result of this request
    public let deleted: Int?
    
    /// The number of filtered stream rules not deleted as a result of this request
    public let notDeleted: Int?
  }
}

public struct FilteredStreamRule: Codable, Identifiable {
  public typealias ID = String
  
  /// Unique identifier of this rule. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers.
  public let id: ID
  
  /// The rule text as submitted when creating the rule.
  public let value: String
  
  /// The tag label as defined when creating the rule.
  public let tag: String?
}

/// A mutable version of ``FilteredStreamRule`` for creating new rules
public struct MutableFilteredStreamRule: Codable {
  /// The string query for this filtered stream rule
  public var value: String
  
  /// The optional tag for this stream rule
  public var tag: String?
}
