//
//  PaginatedUsersMethodView.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 29/03/2022.
//

import SwiftUI
import Twift

struct PaginatedUsersMethodView: View {
  var users: [User] = []
  var errors: [TwitterAPIError] = []
  var meta: Meta?
  
  var nextPage: () async -> Void
  var prevPage: () async -> Void
  
    var body: some View {
      if !errors.isEmpty {
        Section("Errors") {
          ForEach(errors, id: \.self) { error in
            Text(String(describing: error))
          }
        }
      }
      
      if !users.isEmpty {
        Section {
          AsyncButton {
            await prevPage()
          } label: {
            Label("Previous Page", systemImage: "arrow.backward")
          }.disabled(meta?.previousToken == nil)
          
          AsyncButton {
            await nextPage()
          } label: {
            Label("Next Page", systemImage: "arrow.forward")
          }.disabled(meta?.nextToken == nil)
        }
        Section("Users") {
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
            }
          }
          
          if let previousToken = meta.previousToken {
            StackedLabel("previousToken") {
              Text(previousToken)
                .font(.body.monospaced())
            }
          }
        }
      }
    }
}

struct PaginatedUsersMethodView_Previews: PreviewProvider {
    static var previews: some View {
      PaginatedUsersMethodView {
        return
      } prevPage: {
        return
      }

    }
}
