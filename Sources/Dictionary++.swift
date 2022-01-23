import Foundation

extension Dictionary {
  var queryString: String {
    var parts = [String]()
    
    for (key, value) in self {
      let query: String = "\(key)=\(value)"
      parts.append(query)
    }
    
    return parts.sorted().joined(separator: "&")
  }
  
  func urlEncodedQueryString(using encoding: String.Encoding) -> String {
    var parts = [String]()
    
    for (key, value) in self {
      let keyString = "\(key)".urlEncoded
      let valueString = "\(value)".urlEncoded
      let query: String = "\(keyString)=\(valueString)"
      parts.append(query)
    }
    
    return parts.sorted().joined(separator: "&")
  }
}
