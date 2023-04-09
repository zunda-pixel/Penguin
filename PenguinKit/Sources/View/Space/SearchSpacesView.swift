//
//  SearchSpacesView.swift
//

import Sweet
import SwiftUI

enum SortType: String, CaseIterable, Identifiable {
  case viewers = "Viewers"
  case date = "Date"

  var id: String { rawValue }
}

enum SpaceTab: String, CaseIterable, Identifiable {
  case live = "Live"
  case upcoming = "Upcoming"

  var id: String { rawValue }
}

struct SearchSpacesView: View {
  @StateObject var viewModel: SearchSpacesViewModel

  @ViewBuilder
  func spaceCell(space: Sweet.SpaceModel) -> some View {
    if let viewModel = viewModel.spaceDetailViewModel(space: space) {
      SpaceCell(viewModel: viewModel)
    }
  }
  
  var body: some View {
    VStack {
      TextField(text: $viewModel.searchText) {
        Text("\(Image(systemName: "magnifyingglass")) Search Space")
      }
      .textFieldStyle(.roundedBorder)
      .padding()
      .onSubmit(of: .text) {
        Task {
          await viewModel.fetchSpaces()
        }
      }

      HStack {
        Picker("Space Tab", selection: $viewModel.selectedTab) {
          ForEach(SpaceTab.allCases) { tab in
            Text(tab.rawValue)
              .tag(tab)
          }
        }
        .pickerStyle(.segmented)

        Picker("Sort By", selection: $viewModel.selectedSortType) {
          ForEach(SortType.allCases) { sortType in
            Label(sortType.rawValue, systemImage: "arrow.up.arrow.down")
              .tag(sortType)
          }
        }
      }
      .padding(.horizontal)

      TabView(selection: $viewModel.selectedTab) {
        List {
          Section {
            ForEach(viewModel.liveSpaces) { space in
              spaceCell(space: space)
            }
          }
        }
        .scrollContentBackground(.hidden)
        .tag(SpaceTab.live)

        List {
          Section {
            ForEach(viewModel.scheduledSpaces) { space in
              spaceCell(space: space)
            }
          }
        }
        .scrollContentBackground(.hidden)
        .tag(SpaceTab.upcoming)
      }
      #if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
      #endif
    }
      .scrollContentAttribute()
      .alert(errorHandle: $viewModel.errorHandle)
  }
}
