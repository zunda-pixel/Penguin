//
//  TabSettingsView.swift
//

import SwiftUI
import OrderedCollections

struct TabSettingsView: View {
  @State var tabs: [TabItem]
  @Binding var settings: Settings
  
  init(settings: Binding<Settings>) {
    self._settings = settings
    self.tabs = settings.tabs.wrappedValue
  }
  
  var unSelectedTabs: [TabItem] {
    Array(OrderedSet(TabItem.allCases).symmetricDifference(tabs))
  }
  
  var deleteDisabled: Bool {
    tabs.count < 2
  }
  
  var addDisabled: Bool {
    tabs.count > 4
  }
  
  var body: some View {
    List {
      Section("Select Tab") {
        ForEach(tabs) { tab in
          Label(tab.title, systemImage: tab.systemImage)
        }
        .onMove { source, destination in
          tabs.move(fromOffsets: source, toOffset: destination)
        }
        .onDelete { offsets in
          tabs.remove(atOffsets: offsets)
        }
        .deleteDisabled(deleteDisabled)
      }
    }
    .onDisappear {
      settings.tabs = tabs
    }
    .environment(\.editMode, .constant(.active))
    .toolbar {
      Menu {
        ForEach(unSelectedTabs) { tab in
          Button {
            tabs.append(tab)
          } label: {
            Label(tab.title, systemImage: tab.systemImage)
          }
        }
      } label: {
        Image(systemName: "plus")
      }
      .disabled(addDisabled)
    }
  }
}


struct TabSettingsView_Preview: PreviewProvider {
  struct Preview: View {
    @State var settings = Settings()
    
    var body: some View {
      NavigationStack {
        TabSettingsView(settings: $settings)
      }
    }
  }
  
  static var previews: some View {
    Preview()
  }
}


