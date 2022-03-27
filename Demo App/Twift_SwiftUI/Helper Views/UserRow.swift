//
//  UserRow.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct UserProfileImage: View {
  var url: URL
  
  var body: some View {
    AsyncImage(url: url) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
    } placeholder: {
      Color.gray
    }
    .frame(width: 32, height: 32)
    .cornerRadius(32)
    .overlay {
      Circle().stroke(lineWidth: 1).foregroundColor(.primary.opacity(0.1))
    }
  }
}

struct UserRow: View {
  var user: User
    var body: some View {
      HStack {
        if let pfpUrl = user.profileImageUrl {
          UserProfileImage(url: pfpUrl)
        }
        
        Text(user.name)
        Spacer()
        Text("@\(user.username)")
          .foregroundStyle(.secondary)
      }.contextMenu {
        Button(action: {
          UIPasteboard.general.string = user.id
        }) {
          Label("Copy User ID", systemImage: "doc.on.doc")
        }
      }
    }
}

//struct UserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow()
//    }
//}
