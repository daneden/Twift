import Foundation

extension Date {
  func _ISO8601Format() -> String {
    if #available(iOS 15.0, macOS 12.0, *) {
      return ISO8601Format()
    } else {
      return ISO8601DateFormatter.string(from: self,
                                         timeZone: TimeZone(secondsFromGMT: 0)!,
                                         formatOptions: [.withInternetDateTime])
    }
  }
}

struct _AsyncBytes: AsyncSequence {
  typealias Element = UInt8
  
  private let makeUnderlyingIterator: () -> AsyncIterator
  
  init<I: AsyncIteratorProtocol>(_ underlyingIterator: I) where I.Element == UInt8 {
    makeUnderlyingIterator = { AsyncIterator(underlyingIterator) }
  }
  
  public func makeAsyncIterator() -> AsyncIterator {
    return makeUnderlyingIterator()
  }
  
  struct AsyncIterator: AsyncIteratorProtocol {
    private let _next: () async throws -> Element?
    
    init<I: AsyncIteratorProtocol>(_ base: I) where I.Element == Element {
      var iterator = base
      _next = { try await iterator.next() }
    }
    
    public func next() async throws -> Element? {
      return try await _next()
    }
  }
}

extension _AsyncBytes {
  static func bytes(for request: URLRequest) async throws -> (_AsyncBytes, URLResponse) {
    return try await _URLSessionAsyncBytesDelegate().bytes(for: request)
  }
}

private class _URLSessionAsyncBytesDelegate: NSObject, URLSessionDataDelegate {
  private var responseContinuation: CheckedContinuation<URLResponse, Error>!
  
  private let stream: AsyncThrowingStream<UInt8, Error>
  private let streamContinuation: AsyncThrowingStream<UInt8, Error>.Continuation
  
  override init() {
    var continuation: AsyncThrowingStream<UInt8, Error>.Continuation!
    stream = AsyncThrowingStream { continuation = $0 }
    streamContinuation = continuation
    
    super.init()
  }
  
  func bytes(for request: URLRequest) async throws -> (_AsyncBytes, URLResponse) {
    let response = try await withCheckedThrowingContinuation { continuation in
      responseContinuation = continuation
      
      let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
      streamContinuation.onTermination = { @Sendable _ in session.invalidateAndCancel() }
      session.dataTask(with: request).resume()
    }
    let iterator = AsyncIterator(stream.makeAsyncIterator()) { [streamContinuation] in
      streamContinuation.finish()
    }
    return (_AsyncBytes(iterator), response)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if task.response == nil, let error = error {
      // Client-side error
      responseContinuation.resume(throwing: error)
    }
    streamContinuation.finish(throwing: error)
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
    responseContinuation.resume(returning: response)
    return .allow
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    for b in data {
      streamContinuation.yield(b)
    }
  }
  
  struct AsyncIterator: AsyncIteratorProtocol {
    private var base: AsyncThrowingStream<UInt8, Error>.AsyncIterator
    private let token: Token
    
    init(_ underlyingIterator: AsyncThrowingStream<UInt8, Error>.AsyncIterator, onDeinit: @escaping () -> Void) {
      base = underlyingIterator
      token = Token(onDeinit: onDeinit)
    }
    
    mutating func next() async throws -> UInt8? {
      return try await base.next()
    }
    
    private final class Token {
      private let onDeinit: () -> Void
      
      init(onDeinit: @escaping () -> Void) {
        self.onDeinit = onDeinit
      }
      
      deinit { onDeinit() }
    }
  }
}
