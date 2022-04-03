//
//  Lists.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 29/03/2022.
//

import SwiftUI

struct Lists: View {
    var body: some View {
      Form {
        NavigationLink(destination: GetLists()) { MethodRow(label: "`getUserOwnedLists()`", method: .GET) }
        NavigationLink(destination: CreateList()) { MethodRow(label: "`createList(name:description:isPrivate)`", method: .POST) }
      }.navigationTitle("Lists")
    }
}

struct Lists_Previews: PreviewProvider {
    static var previews: some View {
        Lists()
    }
}
