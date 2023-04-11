//
//  SearchSpacesViewModel.swift
//

import Foundation
import Sweet

@MainActor final class SearchSpacesViewModel: ObservableObject {
  let userID: String

  @Published var selectedSortType: SortType
  @Published var selectedTab: SpaceTab
  @Published var searchText: String = ""
  @Published var spaces: [Sweet.SpaceModel]
  @Published var users: [Sweet.UserModel]
  @Published var errorHandle: ErrorHandle?

  init(userID: String) {
    self.userID = userID
    self.selectedSortType = .viewers
    self.selectedTab = .live
    self.searchText = ""
    self.spaces = []
    self.users = []
  }

  func compare(space1: Sweet.SpaceModel, space2: Sweet.SpaceModel, status: Sweet.SpaceState) -> Bool
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

  var liveSpaces: [Sweet.SpaceModel] {
    spaces.lazy.filter { $0.state == .live }.sorted {
      compare(space1: $0, space2: $1, status: .live)
    }
  }

  var scheduledSpaces: [Sweet.SpaceModel] {
    spaces.lazy.filter { $0.state == .scheduled }.sorted {
      compare(space1: $0, space2: $1, status: .scheduled)
    }
  }

  func fetchSpaces() async {
    let removedSpaceSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !removedSpaceSearchText.isEmpty else {
      spaces = []
      users = []
      return
    }

    do {
      let response = try await Sweet(userID: userID).searchSpaces(by: removedSpaceSearchText)

      users = response.users
      spaces = response.spaces
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func spaceDetailViewModel(space: Sweet.SpaceModel) -> SpaceDetailViewModel? {
    guard let creator = users.first(where: { $0.id == space.creatorID }) else {
      return nil
    }

    let speakers = users.filter { space.speakerIDs.contains($0.id) }

    return SpaceDetailViewModel(userID: userID, space: space, creator: creator, speakers: speakers)
  }
}
