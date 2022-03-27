//
//  AsyncButton.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI

extension AsyncButton {
  enum ActionOption: CaseIterable {
    case disableButton
    case showProgressView
  }
}

struct AsyncButton<Label: View>: View {
  var action: () async -> Void
  var actionOptions = Set(ActionOption.allCases)
  @ViewBuilder var label: () -> Label
  
  @State private var isDisabled = false
  @State private var showProgressView = false
  
  var body: some View {
    Button(
      action: {
        if actionOptions.contains(.disableButton) {
          isDisabled = true
        }
        
        Task {
          var progressViewTask: Task<Void, Error>?
          
          if actionOptions.contains(.showProgressView) {
            progressViewTask = Task {
              try await Task.sleep(nanoseconds: 150_000_000)
              showProgressView = true
            }
          }
          
          await action()
          progressViewTask?.cancel()
          
          isDisabled = false
          showProgressView = false
        }
      },
      label: {
        HStack {
          label()
          Spacer()
          if showProgressView {
            ProgressView()
          }
        }
      }
    )
      .disabled(isDisabled)
  }
}

struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
      AsyncButton {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
      } label: {
        Label("Do something", systemImage: "cursorarrow.rays")
      }
      .previewLayout(.sizeThatFits)

    }
}
