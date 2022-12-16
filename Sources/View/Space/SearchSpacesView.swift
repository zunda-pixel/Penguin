//
//  SearchSpacesView.swift
//

import Sweet
import SwiftUI
import os

struct SearchSpacesView: View {
  enum SortType: String, CaseIterable, Identifiable {
    case viewers = "Viewers"
    case date = "Date"
    
    var id: String { rawValue }
  }
  
  let userID: String
  
  @State var selectedSortType: SortType = .viewers
  @StateObject var router = NavigationPathRouter()
  @State var searchText: String = ""
  @State var spaces: [Sweet.SpaceModel] = []
  @State var users: [Sweet.UserModel] = []
  @State var selectedTab: SpaceTab = .live
  @State var errorHandle: ErrorHandle?
  
  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings
  
  enum SpaceTab: String, CaseIterable, Identifiable {
    case live = "Live"
    case upcoming = "Upcoming"
    
    var id: String { rawValue }
  }
  
  var liveSpaces: [Sweet.SpaceModel] {
    spaces.lazy.filter { $0.state == .live }.sorted {
      compareSpace(space1: $0, space2: $1, status: .live)
    }
  }
  
  var scheduledSpaces: [Sweet.SpaceModel] {
    spaces.lazy.filter { $0.state == .scheduled }.sorted {
      compareSpace(space1: $0, space2: $1, status: .scheduled)
    }
  }
  
  func compareSpace(space1: Sweet.SpaceModel, space2: Sweet.SpaceModel, status: Sweet.SpaceState)
  -> Bool
  {
    switch selectedSortType {
    case .viewers:
      return space1.speakerIDs.count > space2.speakerIDs.count
    case .date:
      switch status {
      case .scheduled:
        return space1.scheduledStart! < space2.scheduledStart!
      case .live:
        return space1.startedAt! > space2.startedAt!
      default:
        fatalError()
      }
    }
  }
  
  func fetchSpaces() async {
    guard !searchText.isEmpty else {
      spaces = []
      users = []
      return
    }
    
    do {
      let response = try await Sweet(userID: userID).searchSpaces(by: searchText)
      
      users = response.users
      spaces = response.spaces
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
  
  @ViewBuilder
  func spaceCell(space: Sweet.SpaceModel) -> some View {
    let creator = users.first { $0.id == space.creatorID }
    let speakers = users.filter { space.speakerIDs.contains($0.id) }
    
    if let creator {
      SpaceCell(
        userID: userID,
        space: space,
        creator: creator,
        speakers: speakers
      )
    }
  }
  
  var body: some View {
    NavigationStack(path: $router.path) {
      VStack {
        TextField(text: $searchText) {
          Text("\(Image(systemName: "magnifyingglass")) Search Space")
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .onSubmit(of: .text) {
          Task {
            await fetchSpaces()
          }
        }
        
        HStack {
          Picker("Space Tab", selection: $selectedTab) {
            ForEach(SpaceTab.allCases) { tab in
              Text(tab.rawValue)
                .tag(tab)
            }
          }
          .pickerStyle(.segmented)
          
          Picker("Sort By", selection: $selectedSortType) {
            ForEach(SortType.allCases) { sortType in
              Label(sortType.rawValue, systemImage: "arrow.up.arrow.down")
                .tag(sortType)
            }
          }
        }
        .padding(.horizontal)
              
        TabView(selection: $selectedTab) {
          List {
            Section {
              ForEach(liveSpaces) { space in
                spaceCell(space: space)
              }
            }
          }
          .scrollContentBackground(.hidden)
          .tag(SpaceTab.live)

          List {
            Section {
              ForEach(scheduledSpaces) { space in
                spaceCell(space: space)
              }
            }
          }
          .scrollContentBackground(.hidden)
          .tag(SpaceTab.upcoming)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
      .scrollContentAttribute()
      .navigationBarAttribute()
      .alert(errorHandle: $errorHandle)
      .navigationTitle("Search Space")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination()
      .toolbar {
        TopToolBar(currentUser: $currentUser, loginUsers: $loginUsers, settings: $settings)
      }
    }
    .environmentObject(router)
  }
}
