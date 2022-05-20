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
  @State var meta: Meta?
  @State var includes: Tweet.Includes?
  
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("User ID", text: $userId)
          .keyboardType(.numberPad)
        
        AsyncButton(action: {
          do {
            let result = try await twitterClient.userMentions(
              userId,
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
            } else {
              print(error.localizedDescription)
            }
          }
        }) {
          Text("Get user mentions")
        }.disabled(userId.isEmpty)
      }
      
      PaginatedTweetsMethodView(tweets: tweets,
                                errors: errors,
                                includes: includes,
                                meta: meta,
                                getPage: getPage)
    }.navigationTitle("Get User Mentions")
  }
  
  func getPage(_ token: String?) async {
    do {
      let result = try await twitterClient.userMentions(
        userId,
        fields: Set(Tweet.publicFields),
        expansions: [.authorId(userFields: [\.profileImageUrl])],
        paginationToken: token
      )
      
      withAnimation {
        tweets = result.data
        includes = result.includes
        errors = result.errors ?? []
        meta = result.meta
      }
    } catch {
      if let error = error as? TwitterAPIError {
        withAnimation { errors = [error] }
      } else {
        print(error.localizedDescription)
      }
    }
  }
}

struct UserMentions_Previews: PreviewProvider {
    static var previews: some View {
        UserMentions()
    }
}
