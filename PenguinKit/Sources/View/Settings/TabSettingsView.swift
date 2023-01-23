//
//  TabSettingsView.swift
//

import OrderedCollections
import SwiftUI

struct TabSettingsView: View {
  @State var tabs: [TabItem]
  @Binding var settings: Settings
  @State var tabStyle: TabStyle

  init(settings: Binding<Settings>) {
    self._settings = settings
    self.tabs = settings.tabs.wrappedValue
    self.tabStyle = settings.tabStyle.wrappedValue
  }

  var unSelectedTabs: [TabItem] {
    Array(OrderedSet(TabItem.allCases).symmetricDifference(tabs))
  }

  var deleteDisabled: Bool {
    tabs.count < 2
  }

  func maxTabCount(_ tabStyle: TabStyle) -> Int {
    switch tabStyle {
    case .tab: return 5
    case .split: return TabItem.allCases.count
    }
  }

  var addDisabled: Bool {
    return maxTabCount(tabStyle) < tabs.count
  }

  var body: some View {
    List {
      Section("Tab Style") {
        Picker("Tab Style", selection: $tabStyle) {
          ForEach(TabStyle.allCases) { tabStyle in
            Text(tabStyle.rawValue)
            .tag(tabStyle)
          }
        }
        .pickerStyle(.segmented)
      }

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
    .onChange(of: tabStyle) { newTabStyle in
      tabs = Array(tabs.prefix(maxTabCount(newTabStyle)))
    }
    .onDisappear {
      settings.tabStyle = tabStyle
      settings.tabs = tabs
      settings.tabStyle = tabStyle
      Secure.settings = settings
    }
    #if !os(macOS)
      .environment(\.editMode, .constant(.active))
    #endif
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
