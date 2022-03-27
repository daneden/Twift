//
//  LikeTweet.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 17/01/2022.
//

import SwiftUI
import Twift

struct LikeTweet: View {
  @EnvironmentObject var twitterClient: Twift
  @State var response: LikeResponse?
  @SceneStorage("tweetId") var tweetId = ""
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("Tweet ID", text: $tweetId)
        TextField("User ID", text: $userId)
        AsyncButton {
          do {
            let result = try await twitterClient.likeTweet(tweetId, userId: userId)
            response = result.data
          } catch {
            print(error)
          }
        } label: {
          Text("Like Tweet")
        }.disabled(tweetId.isEmpty || userId.isEmpty)
      }
      
      Text(String(reflecting: response))
    }
  }
}

struct LikeTweet_Previews: PreviewProvider {
    static var previews: some View {
        LikeTweet()
    }
}
