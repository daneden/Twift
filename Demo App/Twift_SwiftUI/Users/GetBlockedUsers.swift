//
//  GetBlockedUsers.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct GetBlockedUsers: PagedView {
  @EnvironmentObject var twitterClient: Twift
  @State var users: [User] = []
  @State var errors: [TwitterAPIError] = []
  @State var meta: Meta?
  @State var resultCount = ""
  @State var paginationToken = ""
  @SceneStorage("userId") var userId = ""
  
  var body: some View {
    Form {
      Section {
        TextField("User ID", text: $userId)
          .keyboardType(.numberPad)
        
        TextField("Result Count (Default: 100)", text: $paginationToken)
          .keyboardType(.numberPad)
        
        TextField("Pagination Token (Optional)", text: $paginationToken)
        
        AsyncButton(action: {
          await getPage(token: nil)
        }) {
          Text("Get blocked users for user")
        }.disabled(userId.isEmpty)
      }
      
      if let users = users, !users.isEmpty {
        Section("Users") {
          ControlGroup {
            AsyncButton {
              await prevPage()
            } label: {
              Text("Previous Page")
            }.disabled(meta?.previousToken == nil)
            
            AsyncButton {
              await nextPage()
            } label: {
              Text("Next Page")
            }.disabled(meta?.nextToken == nil)
          }
          
          ForEach(users) { user in
            UserRow(user: user)
          }
        }
      }
      
      if let meta = meta {
        Section("Meta") {
          if let count = meta.resultCount {
            StackedLabel("resultCount") {
              Text("\(count)")
            }
          }
          
          if let nextToken = meta.nextToken {
            StackedLabel("nextToken") {
              Text(nextToken)
                .font(.body.monospaced())
            }.contextMenu {
              Button(action: { UIPasteboard.general.string = nextToken }) {
                Label("Copy Token", systemImage: "doc.on.doc")
              }
            }
          }
          
          if let previousToken = meta.previousToken {
            StackedLabel("previousToken") {
              Text(previousToken)
                .font(.body.monospaced())
            }.contextMenu {
              Button(action: { UIPasteboard.general.string = previousToken }) {
                Label("Copy Token", systemImage: "doc.on.doc")
              }
            }
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
    }.navigationTitle("Get Blocked Users")
  }
  
  func nextPage() async {
    if let nextToken = meta?.nextToken {
      await getPage(token: nextToken)
    }
  }
  
  func prevPage() async {
    if let prevToken = meta?.previousToken {
      await getPage(token: prevToken)
    }
  }
  
  func getPage(token: String?) async {
    do {
      let result = try await twitterClient.getBlockedUsers(
        for: userId,
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

struct GetBlockedUsers_Previews: PreviewProvider {
    static var previews: some View {
        GetBlockedUsers()
    }
}
