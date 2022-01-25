import Foundation

extension Twift {
  // MARK: Chunked Media Upload
  /// Uploads media data and returns an ID string that can be used to attach media to Tweets
  /// - Parameters:
  ///   - mediaData: The media data to upload
  ///   - mimeType: The type of media you're uploading
  /// - Returns: A ``MediaUploadResponse`` object containing information about the uploaded media, including its `mediaIdString`, which is used to attach media to Tweets
  public func upload(mediaData: Data, mimeType: Media.MimeType) async throws -> MediaUploadResponse {
    let initializeResponse = try await initializeUpload(data: mediaData, mimeType: mimeType)
    try await appendMediaChunks(mediaKey: initializeResponse.mediaIdString, data: mediaData)
    return try await finalizeUpload(mediaKey: initializeResponse.mediaIdString)
  }
  
  /// Allows the user to provide additional information about the uploaded `mediaId`. This feature is currently only supported for images and GIFs.
  ///
  /// Usage:
  /// 1. Upload media using the `upload(mediaData)` method
  /// 2. Add alt text to the `mediaId` returned from step 1 via this method
  /// 3. Create a Tweet with the `mediaId`
  /// - Parameters:
  ///   - mediaId: The target media to attach alt text to
  ///   - text: The alt text to attach to the `mediaId`
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
}

extension Twift {
  // MARK: Media Helper Methods
  fileprivate func initializeUpload(data: Data, mimeType: Media.MimeType) async throws -> MediaInitResponse {
    guard case .userAccessTokens(let clientCredentials, let userCredentials) = self.authenticationType else {
      throw TwiftError.WrongAuthenticationType(needs: .userAccessTokens)
    }
    
    let url = baseMediaURLComponents().url!
    var initRequest = URLRequest(url: url)
    
    let body = [
      "command": "INIT",
      "media_category": mimeType.mediaCategory,
      "media_type": mimeType.rawValue,
      "total_bytes": "\(data.count)"
    ]
    
    initRequest.oAuthSign(method: "POST",
                          urlFormParameters: body,
                          consumerCredentials: clientCredentials,
                          userCredentials: userCredentials)
    
    let (requestData, _) = try await URLSession.shared.data(for: initRequest)
    
    return try decoder.decode(MediaInitResponse.self, from: requestData)
  }
  
  fileprivate func appendMediaChunks(mediaKey: String, data: Data) async throws {
    guard case .userAccessTokens(let clientCredentials, let userCredentials) = self.authenticationType else {
      throw TwiftError.OAuthTokenError
    }
    
    let dataEncodedAsBase64Strings = chunkData(data)
    
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
    
    return try decoder.decode(MediaUploadResponse.self, from: finalizeResponseData)
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
  let chunkSize = ((1024 * 1000) * 4) // MB
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

public struct MediaUploadResponse: Codable {
  public let mediaId: Int
  public let mediaIdString: String
  public let size: Int
  public let expiresAfterSecs: Int
  public let processingInfo: MediaProcessingInfo?
  
  public struct MediaProcessingInfo: Codable {
    let state: String
    let checkAfterSecs: Int
  }
}
