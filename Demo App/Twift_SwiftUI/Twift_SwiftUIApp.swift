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
    case .oauth2UserAuth(_, _): return true
    }
  }
}

let clientCredentials = OAuthCredentials(
  key: TWITTER_API_KEY,
  secret: TWITTER_API_SECRET
)

class ClientContainer: ObservableObject {
  @Published var client: Twift?
  @KeychainItem(account: "twiftAccount") var twiftAccount
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
          .environmentObject(container)
      } else {
        NavigationView {
          Form {
            Section(
              header: Text("OAuth 2.0 User Authentication"),
              footer: Text("Use this authentication method for most cases. This test app enables all user scopes by default.")
            ) {
              AsyncButton {
                let user = try? await Twift.Authentication().authenticateUser(clientId: CLIENT_ID,
                                                                              redirectUri: URL(string: TWITTER_CALLBACK_URL)!,
                                                                              scope: Set(OAuth2Scope.allCases))
                
                if let user = user {
                  container.client = Twift(oauth2User: user) { token in
                    onTokenRefresh(token)
                  }
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
          }
          .navigationTitle("Choose Auth Type")
          .onAppear {
            if let keychainItem = container.twiftAccount?.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(OAuth2User.self, from: keychainItem) {
              container.client = Twift(oauth2User: decoded, onTokenRefresh: onTokenRefresh)
            }
          }
        }
      }
    }
  }
  
  func onTokenRefresh(_ token: OAuth2User) {
    print(token)
    guard let encoded = try? JSONEncoder().encode(token) else { return }
    container.twiftAccount = String(data: encoded, encoding: .utf8)
  }
}
