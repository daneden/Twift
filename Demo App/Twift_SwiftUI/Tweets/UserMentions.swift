//
//  UserMentions.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 17/01/2022.
//

import SwiftUI
import Twift

struct UserMentions: View {
  @EnvironmentObject var twitterClient: Twift
  @State var tweets: [Tweet]?
  @State var errors: [TwitterAPIError] = []
  
  @State var includes: Tweet.Includes?
  
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("User ID", text: $userId)
          .keyboardType(.numberPad)
        
        AsyncButton(action: {
          do {
            let id = userId.isEmpty ? nil : userId
            let result = try await twitterClient.userMentions(
              id,
              fields: Set(Tweet.publicFields),
              expansions: [.authorId(userFields: [\.profileImageUrl])]
            )
            
            withAnimation {
              tweets = result.data
              includes = result.includes
              errors = result.errors ?? []
            }
          } catch {
            if let error = error as? TwitterAPIError {
              withAnimation { errors = [error] }
            } else if let error = (error as? TwitterAPIManyErrors)?.errors {
              withAnimation { errors = error }
            } else {
              print(error.localizedDescription)
            }
          }
        }) {
          Text("Get user mentions")
        }
      }
      
      if let tweets = tweets {
        Section("Tweets") {
          ForEach(tweets) { tweet in
            HStack(alignment: .top) {
              if let pfpUrl = includes?.users?.first(where: { $0.id == tweet.authorId })?.profileImageUrl {
                UserProfileImage(url: pfpUrl)
              }
              
              TweetRow(tweet: tweet)
            }
          }
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
    }.navigationTitle("Get User Mentions")
  }
}

struct UserMentions_Previews: PreviewProvider {
    static var previews: some View {
        UserMentions()
    }
}
