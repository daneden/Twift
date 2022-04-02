//
//  PostTweet.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 23/01/2022.
//

import SwiftUI
import Twift

struct PostTweet: View {
  @EnvironmentObject var twitterClient: Twift
  @State var text = ""
  @State var tweetId: Tweet.ID?
  
  @State var mediaKey = ""
  
    var body: some View {
      Form {
        Section {
          TextField("Tweet text", text: $text)
        }
        
        Section {
          TextField("Media key", text: $mediaKey)
        }
        
        AsyncButton {
          do {
            let media = mediaKey.isEmpty ? nil : MutableMedia(mediaIds: [mediaKey])
            let tweet = MutableTweet(text: text, media: media)
            
            let response = try await twitterClient.postTweet(tweet)
            
            tweetId = response.data.id
            
            text = ""
            mediaKey = ""
          } catch {
            print(error)
          }
        } label: {
          Text("Post Tweet")
        }.disabled(text.isEmpty)

      }
    }
}

struct PostTweet_Previews: PreviewProvider {
    static var previews: some View {
        PostTweet()
    }
}
