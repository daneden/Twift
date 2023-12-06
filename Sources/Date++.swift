import Foundation

extension Date {
  func ISO8601Format() -> String {
    if #available(iOS 15.0, macOS 12.0, *) {
      return ISO8601Format(.init())
    } else {
      return ISO8601DateFormatter.string(from: self,
                                         timeZone: TimeZone(secondsFromGMT: 0)!,
                                         formatOptions: [.withInternetDateTime])
    }
  }
}
