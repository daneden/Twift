//
//  ContentView.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 12/01/2022.
//

import SwiftUI
import Twift

let callbackURL = URL(string: TWITTER_CALLBACK_URL)!

let dteUserId: User.ID = "23082430"
let jackUserId: User.ID = "12"

struct ContentView: View {
  @EnvironmentObject var clientContainer: ClientContainer
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
          NavigationLink(destination: Tweets()) { Label("Tweets", systemImage: "bubble.left") }
          NavigationLink(destination: Lists()) { Label("Lists", systemImage: "list.star") }
          NavigationLink(destination: UploadMedia()) { Label("Upload Image", systemImage: "photo") }
        }.disabled(!twitterClient.hasUserAuth)
        
        Section {
          NavigationLink(destination: HelpfulIDs()) { Label("Helpful IDs", systemImage: "lifepreserver") }
        }
        
        Section {
          if let user = clientContainer.client?.oauthUser {
            if user.expiresAt < .now {
              Text("OAuth token expired \(user.expiresAt, style: .relative) ago")
            } else {
              Text("OAuth token expires in \(user.expiresAt, style: .relative)")
            }
          }
          
          Button {
            Task {
              try await twitterClient.refreshOAuth2AccessToken(onlyIfExpired: false)
            }
          } label: {
            Text("Refresh access token")
          }
          
          Button(role: .destructive) {
            clientContainer.twiftAccount = nil
            clientContainer.client = nil
          } label: {
            Text("Sign out")
          }
        } footer: {
          Text("Twift functions will automatically refresh the token, or you can manually refresh using the button above")
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
