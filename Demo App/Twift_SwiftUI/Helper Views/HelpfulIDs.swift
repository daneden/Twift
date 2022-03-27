//
//  HelpfulIDs.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 15/01/2022.
//

import SwiftUI

typealias IDAndDescription = (id: String, description: String)

let helpfulIds: [IDAndDescription] = [
  (id: "1136048014974423040", description: "Tweet with Place"),
  (id: "1482386088387911681", description: "Tweet with Poll"),
  (id: dteUserId, description: "User ID (@_dte)")
]

struct HelpfulIDs: View {
    var body: some View {
      Form {
        Text("Tap a list cell to copy the object ID to your clipboard")
          .padding(.vertical, 8)
        ForEach(helpfulIds, id: \.id) { pair in
          Button(action: { UIPasteboard.general.string = pair.id }) {
            StackedLabel(pair.description) {
              Text(pair.id)
                .font(.body.monospaced())
            }
          }
        }
      }.navigationTitle("Helpful Object IDs")
    }
}

struct HelpfulIDs_Previews: PreviewProvider {
    static var previews: some View {
        HelpfulIDs()
    }
}
