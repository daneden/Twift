//
//  GetUser.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct GetUser: View {
  @EnvironmentObject var twitterClient: Twift
  @State var user: User?
  @State var errors: [TwitterAPIError] = []
  
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("User ID", text: $userId)
          .keyboardType(.numberPad)
        
        AsyncButton(action: {
          do {
            let result = try await twitterClient.getUser(userId, fields: allUserFields)
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
          Text("Get user by ID")
        }
        .disabled(userId.isEmpty)
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
    }.navigationTitle("Get User By ID")
  }
}

struct GetUser_Previews: PreviewProvider {
    static var previews: some View {
        GetUser()
    }
}
