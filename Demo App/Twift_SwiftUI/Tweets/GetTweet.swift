//
//  GetTweet.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 15/01/2022.
//

import SwiftUI
import Twift

struct GetTweet: View {
  @EnvironmentObject var twitterClient: Twift
  @State var tweet: Tweet?
  @State var errors: [TwitterAPIError] = []
  
  @State var includes: Tweet.Includes?
  @SceneStorage("tweetId") var tweetId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("Tweet ID", text: $tweetId)
          .keyboardType(.numberPad)
        
        AsyncButton(action: {
          do {
            let result = try await twitterClient.getTweet(
              tweetId,
              fields: Tweet.publicFields,
              expansions: [.mediaKeys(mediaFields: [\.id, \.url])]
            )
            withAnimation {
              tweet = result.data
              includes = result.includes
              errors = result.errors ?? []
            }
          } catch {
            if let error = error as? TwitterAPIError {
              withAnimation { errors = [error] }
            } else {
              print(error.localizedDescription)
            }
          }
        }) {
          Text("Get Tweet by ID")
        }
        .disabled(tweetId.isEmpty)
      }
      
      if let tweet = tweet {
        Section("Tweet") {
          TweetRow(tweet: tweet)
        }
      }
      
      if let includes = includes {
        Section("Expansions") {
          Text(String(reflecting: includes))
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
        }
      }
      
      if !errors.isEmpty {
        Section("Errors") {
          ForEach(errors, id: \.self) { error in
            Text(String(describing: error))
          }
        }
      }
    }.navigationTitle("Get Tweet By ID")
  }
}

struct GetTweet_Previews: PreviewProvider {
    static var previews: some View {
        GetTweet()
    }
}
