//
//  Twift_SwiftUIApp.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 12/01/2022.
//

import SwiftUI
import Twift

extension Twift {
  var hasUserAuth: Bool {
    switch authenticationType {
    case .appOnly(_): return false
    case .userAccessTokens(_, _): return true
    case .oauth2UserAuth(_): return true
    }
  }
}

let clientCredentials = OAuthCredentials(
  key: TWITTER_API_KEY,
  secret: TWITTER_API_SECRET
)

class ClientContainer: ObservableObject {
  @Published var client: Twift?
}

@main
struct Twift_SwiftUIApp: App {
  @StateObject var container = ClientContainer()
  @State var bearerToken = ""
  
  var body: some Scene {
    WindowGroup {
      if let twitterClient = container.client {
        ContentView()
          .environmentObject(twitterClient)
      } else {
        NavigationView {
          Form {
            Section(
              header: Text("OAuth 2.0 User Authentication"),
              footer: Text("Use this authentication method for most cases. This test app enables all user scopes by default.")
            ) {
              AsyncButton {
                let (user, _) = await Twift.Authentication().authenticateUser(clientId: "Sm5PSUhRNW9EZ3NXb0tJQkI5WU06MTpjaQ",
                                                                           redirectUri: URL(string: TWITTER_CALLBACK_URL)!,
                                                                           scope: Set(OAuth2Scope.allCases))
                
                if let user = user {
                  container.client = Twift(.oauth2UserAuth(user))
                  
                  try? await container.client?.refreshOAuth2AccessToken()
                }
              } label: {
                Text("Sign In With Twitter")
              }
            }
            
            Section(
              header: Text("App-Only Bearer Token"),
              footer: Text("Use this authentication method for app-only methods such as filtered streams.")
            ) {
              TextField("Enter Bearer Token", text: $bearerToken)
              Button {
                container.client = Twift(.appOnly(bearerToken: bearerToken))
              } label: {
                Text("Add Bearer Token")
              }.disabled(bearerToken.isEmpty)

            }
          }.navigationTitle("Choose Auth Type")
        }
      }
    }
  }
}
