import Foundation

public enum MediaCategory: String {
  /// The category for video media attached to Tweets
  case tweetVideo = "tweet_video"
  
  /// The category for images attached to Tweets
  case tweetImage = "tweet_image"
  
  /// The category for gifs attached to Tweets
  case tweetGif = "tweet_gif"
}

extension Twift {
  // MARK: Chunked Media Upload
  /// Uploads media data and returns an ID string that can be used to attach media to Tweets
  /// - Warning: This method relies on Twitter's v1.1 media API endpoints and only supports OAuth 1.0a authentication.
  /// - Parameters:
  ///   - mediaData: The media data to upload
  ///   - mimeType: The type of media you're uploading
  ///   - category: The category for the media you're uploading. Defaults to `tweetImage`; this will cause gif and video uploads to error unless the category is set appropriately.
  ///   - progress: An optional pointer to a `Progress` instance, used to track the progress of the upload task.
  ///   The progress is based on the number of base64 chunks the data is split into; each chunk will be approximately 2mb in size.
  /// - Returns: A ``MediaUploadResponse`` object containing information about the uploaded media, including its `mediaIdString`, which is used to attach media to Tweets
  @available(*, deprecated, message: "Media methods currently depend on OAuth 1.0a authentication, which will be deprecated in a future version of Twift. These media methods may be removed or replaced in the future.")
  public func upload(mediaData: Data, mimeType: String, category: MediaCategory, progress: UnsafeMutablePointer<Progress>? = nil) async throws -> MediaUploadResponse {
    let initializeResponse = try await initializeUpload(data: mediaData, mimeType: mimeType)
    try await appendMediaChunks(mediaKey: initializeResponse.mediaIdString, data: mediaData, progress: progress)
    return try await finalizeUpload(mediaKey: initializeResponse.mediaIdString)
  }
  
  /// Allows the user to provide alt text for the `mediaId`. This feature is currently only supported for images and GIFs.
  ///
  /// Usage:
  /// 1. Upload media using the `upload(mediaData)` method
  /// 2. Add alt text to the `mediaId` returned from step 1 via this method
  /// 3. Create a Tweet with the `mediaId`
  /// - Warning: This method relies on Twitter's v1.1 media API endpoints and only supports OAuth 1.0a authentication.
  /// - Parameters:
  ///   - mediaId: The target media to attach alt text to
  ///   - text: The alt text to attach to the `mediaId`
  @available(*, deprecated, message: "Media methods currently depend on OAuth 1.0a authentication, which will be deprecated in a future version of Twift. These media methods may be removed or replaced in the future.")
  public func addAltText(to mediaId: Media.ID, text: String) async throws {
    guard case .userAccessTokens(let clientCredentials, let userCredentials) = self.authenticationType else {
      throw TwiftError.WrongAuthenticationType(needs: .userAccessTokens)
    }
    
    let body: [String: Any] = [
      "media_id": mediaId,
      "alt_text": [
        "text": text
      ]
    ]
    
    let encodedBody = try JSONSerialization.data(withJSONObject: body)
    
    let url = getURL(for: .mediaMetadataCreate)
    var request = URLRequest(url: url)
    
    request.oAuthSign(method: "POST",
                      body: encodedBody,
                      contentType: "application/json",
                      consumerCredentials: clientCredentials,
                      userCredentials: userCredentials)
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let response = response as? HTTPURLResponse,
          response.statusCode >= 200 && response.statusCode < 300 else {
            throw TwiftError.UnknownError(response)
          }
  }
  
  /// Checks to see whether the `mediaId` has finished processing successfully. This method will wait for the `GET /1.1/media/upload.json?command=STATUS` endpoint to return either `succeeded` or `failed`; for large videos, this may take some time.
  /// - Parameter mediaId: The media ID to check the upload status of
  /// - Returns: A `Bool` indicating whether the media has uploaded successfully (`true`) or not (`false`).
  @available(*, deprecated, message: "Media methods currently depend on OAuth 1.0a authentication, which will be deprecated in a future version of Twift. These media methods may be removed or replaced in the future.")
  public func checkMediaUploadSuccessful(_ mediaId: Media.ID) async throws -> Bool {
    var urlComponents = baseMediaURLComponents()
    urlComponents.queryItems = [
      URLQueryItem(name: "command", value: "STATUS"),
      URLQueryItem(name: "media_id", value: mediaId)
    ]
    let url = urlComponents.url!
    var request = URLRequest(url: url)
    
    signURLRequest(method: .GET, request: &request)
    
    let isWaiting = true
    
    while isWaiting {
      let (processingStatus, _) = try await URLSession.shared.data(for: request)
      let status = try decoder.decode(MediaUploadResponse.self, from: processingStatus)
      
      guard let state = status.processingInfo?.state else {
        return false
      }
      
      switch state {
      case .pending:
        break
      case .inProgress:
        break
      case .failed:
        return false
      case .succeeded:
        return true
      }
      
      if let waitPeriod = status.processingInfo?.checkAfterSecs {
        try await Task.sleep(nanoseconds: UInt64(waitPeriod * 1_000_000_000))
      }
    }
  }
}

extension Twift {
  // MARK: Media Helper Methods
  @available(*, deprecated, message: "Media methods currently depend on OAuth 1.0a authentication, which will be deprecated in a future version of Twift. These media methods may be removed or replaced in the future.")
  fileprivate func initializeUpload(data: Data, mimeType: String) async throws -> MediaInitResponse {
    guard case .userAccessTokens(let clientCredentials, let userCredentials) = self.authenticationType else {
      throw TwiftError.WrongAuthenticationType(needs: .userAccessTokens)
    }
    
    let url = baseMediaURLComponents().url!
    var initRequest = URLRequest(url: url)
    
    let body = [
      "command": "INIT",
      "media_type": mimeType,
      "total_bytes": "\(data.count)"
    ]
    
    initRequest.oAuthSign(method: "POST",
                          urlFormParameters: body,
                          consumerCredentials: clientCredentials,
                          userCredentials: userCredentials)
    
    let (requestData, _) = try await URLSession.shared.data(for: initRequest)
    
    return try decoder.decode(MediaInitResponse.self, from: requestData)
  }
  
  fileprivate func appendMediaChunks(mediaKey: String, data: Data, progress: UnsafeMutablePointer<Progress>? = nil) async throws {
    guard case .userAccessTokens(let clientCredentials, let userCredentials) = self.authenticationType else {
      throw TwiftError.OAuthTokenError
    }
    
    let dataEncodedAsBase64Strings = chunkData(data)
    
    progress?.pointee.fileTotalCount = dataEncodedAsBase64Strings.count
    var completed = 0
    
    for chunk in dataEncodedAsBase64Strings {
      let index = dataEncodedAsBase64Strings.firstIndex(of: chunk)!
      
      let body = [
        "command": "APPEND",
        "media_id": mediaKey,
        "media_data": chunk,
        "segment_index": "\(index)"
      ]
      
      let url = baseMediaURLComponents().url!
      var appendRequest = URLRequest(url: url)
      
      appendRequest.addValue("base64", forHTTPHeaderField: "Content-Transfer-Encoding")
      
      appendRequest.oAuthSign(method: "POST",
                              urlFormParameters: body,
                              consumerCredentials: clientCredentials,
                              userCredentials: userCredentials)
      
      let (_, response) = try await URLSession.shared.data(for: appendRequest)
      
      guard let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
              throw TwiftError.UnknownError(response)
            }
      
      completed += 1
      DispatchQueue.main.async { [completed] in
        progress?.pointee.fileCompletedCount = completed
      }
    }
  }
  
  fileprivate func finalizeUpload(mediaKey: String) async throws -> MediaUploadResponse {
    guard case .userAccessTokens(let clientCredentials, let userCredentials) = self.authenticationType else {
      throw TwiftError.OAuthTokenError
    }
    
    let body = [
      "command": "FINALIZE",
      "media_id": mediaKey,
    ]
    
    let url = baseMediaURLComponents().url!
    var finalizeRequest = URLRequest(url: url)
    
    finalizeRequest.oAuthSign(method: "POST",
                              urlFormParameters: body,
                              consumerCredentials: clientCredentials,
                              userCredentials: userCredentials)
    
    let (finalizeResponseData, _) = try await URLSession.shared.data(for: finalizeRequest)
    
    return try decodeOrThrow(decodingType: MediaUploadResponse.self, data: finalizeResponseData)
  }
  
  fileprivate func baseMediaURLComponents() -> URLComponents {
    var urlComponents = URLComponents()
    urlComponents.host = "upload.twitter.com"
    urlComponents.path = "/1.1/media/upload.json"
    urlComponents.scheme = "https"
    
    return urlComponents
  }
}

fileprivate func chunkData(_ data: Data) -> [String] {
  let dataLen = data.count
  let chunkSize = ((1024 * 1000) * 2) // MB
  let fullChunks = Int(dataLen / chunkSize)
  let totalChunks = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)
  
  var chunks: [Data] = []
  for chunkCounter in 0..<totalChunks {
    var chunk: Data
    let chunkBase = chunkCounter * chunkSize
    var diff = chunkSize
    if(chunkCounter == totalChunks - 1) {
      diff = dataLen - chunkBase
    }
    
    let range:Range<Data.Index> = (chunkBase..<(chunkBase + diff))
    chunk = data.subdata(in: range)
    chunks.append(chunk)
  }
  
  return chunks.map { $0.base64EncodedString() }
}

fileprivate struct MediaInitResponse: Codable {
  let mediaId: Int
  let mediaIdString: String
  let expiresAfterSecs: Int
}

/// A response object containing information about the uploaded media
public struct MediaUploadResponse: Codable {
  /// The uploaded media's unique Integer ID
  public let mediaId: Int
  
  /// The uploaded media's ID represented as a `String`. The string representation of the ID is preferred for ensuring precision.
  public let mediaIdString: String
  
  /// The size of the uploaded media
  public let size: Int?
  
  /// When this media upload will expire, if not attached to a Tweet
  public let expiresAfterSecs: Int?
  
  /// Information about the media's processing status. Most images are processed instantly, but large gifs and videos may take longer to process before they can be used in a Tweet.
  ///
  /// Use the ``Twift.checkMediaUploadSuccessful()`` method to wait until the media is successfully processed.
  public let processingInfo: MediaProcessingInfo?
  
  /// An object containing information about the media's processing status.
  public struct MediaProcessingInfo: Codable {
    /// The current processing state of the media
    public let state: State
    
    /// How many seconds the user is advised to wait before checking the status of the media again
    public let checkAfterSecs: Int?
    
    /// The percent completion of the media processing
    public let progressPercent: Int?
    
    /// Any errors that caused the media processing to fail
    public let error: ProcessingError?
    
    public enum State: String, Codable {
      /// The media is queued to be processed
      case pending
      
      /// The media is currently being processed
      case inProgress = "in_progress"
      
      /// The media could not be processed
      case failed
      
      /// The media was successfully processed and is ready to be attached to a Tweet
      case succeeded
    }
    
    /// An error associated with media processing
    public struct ProcessingError: Codable {
      /// The status code for this error
      public let code: Int
      
      /// The name of the error
      public let name: String
      
      /// A longer description of the processing error
      public let message: String?
    }
  }
}
