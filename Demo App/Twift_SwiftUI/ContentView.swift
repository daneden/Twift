//
//  ContentView.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 12/01/2022.
//

import SwiftUI
import Twift

let callbackURL = URL(string: "twift-test://")!

let dteUserId: User.ID = "23082430"
let jackUserId: User.ID = "12"

struct ContentView: View {
  @EnvironmentObject var twitterClient: Twift
  
  var userId: String? {
    if case .userAccessTokens(_, let userCredentials) = twitterClient.authenticationType {
      return userCredentials.userId
    } else {
      return nil
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          Text("This simple SwiftUI app showcases the various capabilities of the Twift library. Navigate into each category to explore the library methods.")
            .padding(.vertical, 8)
  
          if let userId = userId {
            HStack {
              StackedLabel("Current User ID") {
                Text(userId).font(.body.monospaced())
              }
              
              Spacer()
              
              Button {
                UIPasteboard.general.string = userId
              } label: {
                Label("Copy", systemImage: "doc.on.doc")
              }
            }
          }
        }
        
        Section("Examples") {
          NavigationLink(destination: Users()) { Label("Users", systemImage: "person") }
            .disabled(!twitterClient.hasUserAuth)
          NavigationLink(destination: Tweets()) { Label("Tweets", systemImage: "bubble.left") }
            .disabled(!twitterClient.hasUserAuth)
          
          NavigationLink(destination: UploadMedia()) { Label("Upload Image", systemImage: "photo") }
            .disabled(!twitterClient.hasUserAuth)
        }
        
        Section {
          NavigationLink(destination: HelpfulIDs()) { Label("Helpful IDs", systemImage: "lifepreserver") }
        }
      }
      .navigationTitle("Twift Example App")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
