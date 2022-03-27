//
//  MultiPicker.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI

struct MultiPicker<T: Hashable, Label: View>: View {
  @Binding var selection: Set<T>
  var items: Set<T>
  var labelKeyPath: KeyPath<T, String>
  var label: Label
  
  private var sortedItems: Array<T> {
    items.sorted { lhs, rhs in
      lhs[keyPath: labelKeyPath].localizedCompare(rhs[keyPath: labelKeyPath]) == .orderedAscending
    }
  }
  
  init(selection: Binding<Set<T>>, items: Set<T>, labelKeyPath: KeyPath<T, String>, label: @escaping () -> Label) {
    self._selection = selection
    self.items = items
    self.labelKeyPath = labelKeyPath
    self.label = label()
  }
  
  var body: some View {
    NavigationLink(destination: MultiPickerList(selection: $selection, items: items, labelKeyPath: labelKeyPath)) {
      HStack {
        label
        Spacer()
        Text("\(selection.count)").foregroundStyle(.secondary)
      }
    }
  }
}

fileprivate struct MultiPickerList<T: Hashable>: View {
  @Binding var selection: Set<T>
  var items: Set<T>
  var labelKeyPath: KeyPath<T, String>
  
  private var sortedItems: Array<T> {
    items.sorted { lhs, rhs in
      lhs[keyPath: labelKeyPath].localizedCompare(rhs[keyPath: labelKeyPath]) == .orderedAscending
    }
  }
  
  var body: some View {
    List(sortedItems, id: \.self) { item in
      HStack {
        Text(item[keyPath: labelKeyPath])
        Spacer()
        if selection.contains(item) {
          Label("Currently selected", systemImage: "checkmark")
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.multicolor)
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        withAnimation(.interactiveSpring()) {
          if selection.contains(item) {
            selection.remove(item)
          } else {
            selection.insert(item)
          }
        }
      }
      .tag(item)
    }.toolbar {
      Button(action: {
        for item in sortedItems {
          selection.insert(item)
        }
      }) {
        Text("Select all")
      }
    }
  }
}
