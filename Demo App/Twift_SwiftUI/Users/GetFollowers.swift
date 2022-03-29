//
//  GetFollowers.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct GetFollowers: PagedView {
  @EnvironmentObject var twitterClient: Twift
  @State var users: [User] = []
  @State var errors: [TwitterAPIError] = []
  @State var meta: Meta?
  @State var resultCount = ""
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("User ID", text: $userId)
          .keyboardType(.numberPad)
        
        TextField("Result Count (Default: 10)", text: $resultCount)
          .keyboardType(.numberPad)
        
        AsyncButton(action: {
          await getPage(nil)
        }) {
          Text("Get followers for user")
        }.disabled(userId.isEmpty)
      }
      
      PaginatedUsersMethodView(users: users,
                               errors: errors,
                               meta: meta,
                               getPage: getPage)
    }.navigationTitle("Get Followers")
  }
  
  func getPage(_ token: String?) async {
    do {
      let result = try await twitterClient.getFollowers(
        userId,
        fields: allUserFields,
        paginationToken: token,
        maxResults: Int(resultCount) ?? 100
      )
      withAnimation {
        users = result.data
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

struct GetFollowers_Previews: PreviewProvider {
    static var previews: some View {
        GetFollowers()
    }
}
