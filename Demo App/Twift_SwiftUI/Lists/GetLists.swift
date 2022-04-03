//
//  GetLists.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 03/04/2022.
//

import SwiftUI
import Twift

struct GetLists: View {
  private let title = "Get Lists"
  
  @EnvironmentObject var twitterClient: Twift
  @SceneStorage("userId") var userId = ""
  @State var lists: [TwitterList] = []
  
  var body: some View {
    Form {
      Section {
        TextField("User ID", text: $userId)
        
        AsyncButton {
          do {
            let result = try await twitterClient.getUserOwnedLists(userId, fields: [\.description], expansions: [])
            
            withAnimation {
              lists = result.data
            }
          } catch {
            print(error.localizedDescription)
          }
        } label: {
          Text(title)
        }.disabled(userId.isEmpty)
      }
      
      if !lists.isEmpty {
        Section {
          ForEach(lists) { list in
            VStack(alignment: .leading) {
              Text(list.name)
              if let description = list.description {
                Text(description).foregroundStyle(.secondary)
              }
            }
          }
        } header: {
          Text("Lists")
        }
      }
    }.navigationTitle(title)
  }
}

struct GetLists_Previews: PreviewProvider {
    static var previews: some View {
        GetLists()
    }
}
