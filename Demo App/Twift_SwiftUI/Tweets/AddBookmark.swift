//
//  AddBookmark.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 17/01/2022.
//

import SwiftUI
import Twift

struct AddBookmark: View {
  @EnvironmentObject var twitterClient: Twift
  @State var response: BookmarkResponse?
  @SceneStorage("tweetId") var tweetId = ""
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("Tweet ID", text: $tweetId)
        TextField("User ID", text: $userId)
        AsyncButton {
          do {
            let result = try await twitterClient.addBookmark(tweetId, userId: userId)
            response = result.data
          } catch {
            print(error)
          }
        } label: {
          Text("Add Bookmark")
        }.disabled(tweetId.isEmpty || userId.isEmpty)
      }
      
      Text(String(reflecting: response))
    }
  }
}

struct AddBookmark_Previews: PreviewProvider {
  static var previews: some View {
    AddBookmark()
  }
}
