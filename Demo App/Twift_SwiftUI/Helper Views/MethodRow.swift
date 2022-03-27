//
//  MethodRow.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 15/01/2022.
//

import SwiftUI

struct MethodRow: View {
  var label: String
  var method: HTTPMethod
  
  var attributedLabel: AttributedString {
    try! AttributedString(markdown: label)
  }
  
  var body: some View {
    HStack {
      Text(attributedLabel)
      Spacer()
      HTTPMethodBadge(method: method)
    }.lineLimit(1)
  }
}

struct MethodRow_Previews: PreviewProvider {
    static var previews: some View {
      MethodRow(label: "`getMe()`", method: .GET)
    }
}
