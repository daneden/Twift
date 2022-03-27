//
//  GetUserByUsername.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct GetUserByUsername: View {
  @EnvironmentObject var twitterClient: Twift
  @State var user: User?
  @State var errors: [TwitterAPIError] = []
  @State var username = ""
  
  var body: some View {
    Form {
      Section {
        TextField("Username", text: $username)
        AsyncButton(action: {
          do {
            let result = try await twitterClient.getUserBy(username: username, fields: allUserFields)
            withAnimation {
              user = result.data
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
          Text("Get user by username")
        }
        .disabled(username.count < 1)
      }
      
      if let user = user {
        Section("User") {
          UserRow(user: user)
        }
      }
      
      if !errors.isEmpty {
        Section("Errors") {
          ForEach(errors, id: \.self) { error in
            Text(String(describing: error))
          }
        }
      }
    }.navigationTitle("Get User By Username")
  }
}

struct GetUserByUsername_Previews: PreviewProvider {
    static var previews: some View {
        GetUserByUsername()
    }
}
