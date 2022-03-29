//
//  UserTimeline.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 16/01/2022.
//

import SwiftUI
import Twift

struct UserTimeline: View {
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
              let result = try await twitterClient.userTimeline(
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
              } else if let errors = (error as? TwitterAPIManyErrors)?.errors {
                withAnimation { self.errors = errors }
              } else {
                print(error.localizedDescription)
              }
            }
          }) {
            Text("Get user timeline")
          }
        }
        
        TweetsMethodView(tweets: tweets, errors: errors, includes: includes)
      }.navigationTitle("Get User Timeline")
    }
  
  func userForTweet(tweet: Tweet) -> User? {
    guard let authorId = tweet.authorId else { return nil }
    
    return includes?.users?.first(where: { $0.id == authorId })
  }
}

struct UserTimeline_Previews: PreviewProvider {
    static var previews: some View {
        UserTimeline()
    }
}
