//
//  StackedLabel.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI

struct StackedLabel<Content: View>: View {
  var label: String
  var content: Content
  
  init(_ label: String, content: @escaping () -> Content) {
    self.label = label
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(label).font(.caption).foregroundStyle(.secondary)
      content
    }
  }
}
