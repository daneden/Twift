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
              header: Text("User Access Tokens"),
              footer: Text("Use this authentication method for most cases.")
            ) {
              Button {
                Twift.Authentication().requestUserCredentials(clientCredentials: clientCredentials, callbackURL: URL(string: TWITTER_CALLBACK_URL)!) { (userCredentials, error) in
                  if let error = error {
                    print(error.localizedDescription)
                  }
                  
                  if let creds = userCredentials {
                    DispatchQueue.main.async {
                      container.client = Twift(.userAccessTokens(clientCredentials: clientCredentials, userCredentials: creds))
                    }
                  }
                }
              } label: {
                Text("Sign In With Twitter")
              }
            }
            
            Section(
              header: Text("App-Only Bearer Token"),
              footer: Text("Use this authentication method for app-only methods such as filtered streams")
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
