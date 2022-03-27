//
//  UploadMedia.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 20/01/2022.
//

import SwiftUI
import Twift

struct UploadMedia: View {
  @EnvironmentObject var twitterClient: Twift
  @State var image: UIImage?
  @State var isPickingPhoto = false
  var body: some View {
    Form {
      Button(action: { isPickingPhoto = true }) {
        Text("Choose photo")
      }
      
      AsyncButton {
        do {
          if let imageData = image?.pngData() {
            let response = try await twitterClient.upload(mediaData: imageData, mimeType: "image/png", category: .tweetImage)
            print(response)
          }
        } catch {
          print(error.localizedDescription)
        }
      } label: {
        Text("Upload image")
      }.disabled(image == nil)
      
    }.sheet(isPresented: $isPickingPhoto) {
      ImagePicker(chosenImage: $image)
    }.navigationTitle("Upload Image")
  }
}

struct UploadMedia_Previews: PreviewProvider {
  static var previews: some View {
    UploadMedia()
  }
}
