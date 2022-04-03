//
//  GetBookmarks.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 03/04/2022.
//

import SwiftUI
import Twift

struct GetBookmarks: PagedView {
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
          await getPage(nil)
        }) {
          Text("Get bookmarks")
        }
      }
      
      PaginatedTweetsMethodView(tweets: tweets,
                                errors: errors,
                                includes: includes,
                                meta: meta,
                                getPage: getPage)
      
    }.navigationTitle("Get Bookmarks")
  }
  
  func userForTweet(tweet: Tweet) -> User? {
    guard let authorId = tweet.authorId else { return nil }
    
    return includes?.users?.first(where: { $0.id == authorId })
  }
  
  func getPage(_ token: String?) async {
    do {
      let result = try await twitterClient.getBookmarks(
        for: userId,
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

struct GetBookmarks_Previews: PreviewProvider {
  static var previews: some View {
    GetBookmarks()
  }
}
