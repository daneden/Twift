//
//  GetUsers.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct GetUsersByUsernames: View {
  @EnvironmentObject var twitterClient: Twift
  @State var users: [User] = []
  @State var errors: [TwitterAPIError] = []
  @State var textFieldValue = ""
  
  var usernames: [String] {
    textFieldValue.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
  }
  
  var body: some View {
    Form {
      Section {
        TextField("Comma-separated usernames", text: $textFieldValue)
        AsyncButton(action: {
          do {
            let result = try await twitterClient.getUsersBy(usernames: usernames, fields: allUserFields)
            withAnimation {
              users = result.data
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
          Text("Get users by usernames")
        }.disabled(usernames.isEmpty)
      }
      
      if let users = users, !users.isEmpty {
        Section("Users") {
          ForEach(users) { user in
            UserRow(user: user)
          }
        }
      }
      
      if !errors.isEmpty {
        Section("Errors") {
          ForEach(errors, id: \.self) { error in
            Text(String(describing: error))
          }
        }
      }
    }.navigationTitle("Get Users By Username")
  }
}

struct GetUsers_Previews: PreviewProvider {
    static var previews: some View {
        GetUsersByUsernames()
    }
}
