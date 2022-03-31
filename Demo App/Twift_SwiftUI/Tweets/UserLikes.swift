//
//  UserLikes.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 19/01/2022.
//

import SwiftUI
import Twift

struct UserLikes: View {
  @EnvironmentObject var twitterClient: Twift
  @State var tweets: [Tweet] = []
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
          await getPage()
        }) {
          Text("Get user likes")
        }
        .disabled(userId.isEmpty)
      }
      
      PaginatedTweetsMethodView(tweets: tweets,
                                errors: errors,
                                includes: includes,
                                meta: meta,
                                getPage: getPage)
    }.navigationTitle("Get User Likes")
  }
  
  func getPage(_ token: String? = nil) async {
    do {
      let result = try await twitterClient.getLikedTweets(
        for: userId,
        fields: Set(Tweet.publicFields),
        expansions: [.authorId(userFields: [\.profileImageUrl])],
        paginationToken: token,
        maxResults: 100
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
        print(error)
      }
    }
  }
}

struct UserLikes_Previews: PreviewProvider {
    static var previews: some View {
        UserLikes()
    }
}
