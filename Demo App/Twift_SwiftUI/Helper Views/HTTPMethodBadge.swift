//
//  HTTPMethodBadge.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 15/01/2022.
//

import SwiftUI

enum HTTPMethod: String, CaseIterable {
  case GET, POST, DELETE
}

struct HTTPMethodBadge: View {
  var method: HTTPMethod
  
  var color: Color {
    switch method {
    case .GET:
      return .blue
    case .POST:
      return .purple
    case .DELETE:
      return .red
    }
  }
  
  var body: some View {
    Text(method.rawValue)
      .padding(4)
      .padding(.horizontal, 4)
      .font(.caption.monospaced().weight(.semibold))
      .foregroundStyle(.primary)
      .background(.quaternary)
      .foregroundStyle(color)
      .cornerRadius(8)
      
  }
}

struct HTTPMethodBadge_Previews: PreviewProvider {
    static var previews: some View {
      ForEach(HTTPMethod.allCases, id: \.self) { method in
        HTTPMethodBadge(method: method)
      }
    }
}
