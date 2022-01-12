import Foundation

extension Twift {
  func getURLComponents(for route: APIRoute) -> URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.twitter.com"
    components.path = "/2/\(route.rawValue)"
    
    return components
  }
}
