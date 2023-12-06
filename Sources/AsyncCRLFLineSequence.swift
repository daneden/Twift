import Foundation

// AsyncLineSequence but separated by CRLF only
struct AsyncCRLFLineSequence<Base: AsyncSequence>: AsyncSequence where Base.Element == UInt8 {
  typealias Element = String
  
  private let base: Base
  
  struct AsyncIterator: AsyncIteratorProtocol {
    private var byteSource: Base.AsyncIterator
    private var buffer = [UInt8]()
    
    init(underlyingIterator: Base.AsyncIterator) {
      byteSource = underlyingIterator
    }
    
    mutating func next() async rethrows -> String? {
      let _CR: UInt8 = 0x0D
      let _LF: UInt8 = 0x0A
      
      func yield() -> String? {
        defer {
          buffer.removeAll(keepingCapacity: true)
        }
        if buffer.isEmpty {
          return nil
        }
        return String(decoding: buffer, as: UTF8.self)
      }
      
      while let first = try await byteSource.next() {
        switch first {
        case _CR:
          // Try to read: 0D [0A].
          guard let next = try await byteSource.next() else {
            buffer.append(first)
            return yield()
          }
          guard next == _LF else {
            buffer.append(first)
            buffer.append(next)
            continue
          }
          if let result = yield() {
            return result
          }
        default:
          buffer.append(first)
        }
      }
      // Don't emit an empty newline when there is no more content (e.g. end of file)
      if !buffer.isEmpty {
        return yield()
      }
      return nil
    }
  }
  
  func makeAsyncIterator() -> AsyncIterator {
    return AsyncIterator(underlyingIterator: base.makeAsyncIterator())
  }
  
  init(underlyingSequence: Base) {
    base = underlyingSequence
  }
}

extension AsyncSequence where Self.Element == UInt8 {
  /**
   A non-blocking sequence of CRLF-separated `Strings` created by decoding the elements of `self` as UTF8.
   */
  var linesCRLF: AsyncCRLFLineSequence<Self> {
    AsyncCRLFLineSequence(underlyingSequence: self)
  }
}
