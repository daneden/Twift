//
//  UnmuteUser.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct UnmuteUser: View {
  @EnvironmentObject var twitterClient: Twift
  @State var muteResult: MuteResponse?
  @State var errors: [TwitterAPIError] = []
  @SceneStorage("userId") var sourceUserId = ""
  @State var targetUserId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("Source User ID", text: $sourceUserId)
          .keyboardType(.numberPad)
        
        TextField("Target User ID", text: $targetUserId)
          .keyboardType(.numberPad)
        
        AsyncButton(action: {
          do {
            let result = try await twitterClient.unmuteUser(
              sourceUserId: sourceUserId,
              targetUserId: targetUserId
            )
            
            withAnimation {
              muteResult = result.data
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
          Text("Unmute user")
        }.disabled(sourceUserId.isEmpty || targetUserId.isEmpty)
      } footer: {
        VStack(alignment: .leading) {
          Text("Note that the `sourceUserId` must be the currently-authenticated user or this request will fail.")
        }
      }
      
      if let muteResult = muteResult {
        Section("Result") {
          StackedLabel("muting") {
            Text(String(describing: muteResult.muting))
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
    }.navigationTitle("Unmute User")
  }
}

struct UnmuteUser_Previews: PreviewProvider {
  static var previews: some View {
    UnmuteUser()
  }
}
