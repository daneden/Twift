import Foundation

extension Twift {
  // MARK: Spaces Lookup
  
  /// Returns a variety of information about a single Space specified by the requested ID.
  /// - Parameters:
  ///   - id: Unique identifier of the Space to request.
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the requested Space and any requested expansions
  public func getSpace(_ id: Space.ID,
                       fields: Set<Space.Field>,
                       expansions: [Space.Expansions]
  ) async throws -> TwitterAPIDataAndIncludes<Space, Space.Includes> {
    return try await call(route: .spaces(id),
                          method: .GET,
                          queryItems: fieldsAndExpansions(for: Space.self, fields: fields, expansions: expansions),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
  
  /// Returns details about multiple Spaces. Up to 100 comma-separated Spaces IDs can be looked up using this endpoint.
  /// - Parameters:
  ///   - ids: A comma separated list of Spaces (up to 100).
  ///   - fields: Any additional fields to include on returned objects
  ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
  /// - Returns: A response object containing the requested Space and any requested expansions
  public func getSpaces(_ ids: [Space.ID],
                       fields: Set<Space.Field>,
                       expansions: [Space.Expansions]
  ) async throws -> TwitterAPIDataAndIncludes<[Space], Space.Includes> {
    let queryItems = [URLQueryItem(name: "ids", value: ids.joined(separator: ","))]
    return try await call(route: .spaces(),
                          method: .GET,
                          queryItems: queryItems + fieldsAndExpansions(for: Space.self, fields: fields, expansions: expansions),
                          expectedReturnType: TwitterAPIDataAndIncludes.self)
  }
}
