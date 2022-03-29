//
//  CreateList.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 29/03/2022.
//

import SwiftUI
import Twift

struct CreateList: View {
  @EnvironmentObject var twitterClient: Twift
  @State var listName = ""
  @State var listDescription = ""
  @State var isPrivate = false
  
    var body: some View {
      Form {
        Section {
          TextField("List name", text: $listName)
          TextField("List description", text: $listDescription)
          Toggle("Private list", isOn: $isPrivate)
          
          AsyncButton {
            do {
              let result = try await twitterClient.createList(name: listName,
                                                              description: listDescription,
                                                              isPrivate: isPrivate)
              print(result)
            } catch {
              print(error.localizedDescription)
            }
          } label: {
            Text("Create List")
          }.disabled(listName.isEmpty)
        }
      }.navigationTitle("Create List")
    }
}

struct CreateList_Previews: PreviewProvider {
    static var previews: some View {
        CreateList()
    }
}
