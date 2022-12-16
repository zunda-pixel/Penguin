//
//  SpaceDetail.swift
//

import SwiftUI

struct SpaceDetail: View {
  @ObservedObject var viewModel: SpaceDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter

  var speakersView: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(viewModel.speakers) { speaker in
          ProfileImageView(url: speaker.profileImageURL!)
            .frame(width: 60, height: 60)
            .padding(.vertical)
            .onTapGesture {
              let userViewModel: UserDetailViewModel = .init(
                userID: viewModel.userID,
                user: speaker
              )
              router.path.append(userViewModel)
            }
        }
      }
      .padding(.horizontal, 50)
    }
  }
  
  var spaceInfoView: some View {
    VStack {
      Text(viewModel.space.title!)
        .font(.title)
      
      ProfileImageView(url: viewModel.creator.profileImageURL!)
        .frame(width: 100, height: 100)
        .onTapGesture {
          let userViewModel: UserDetailViewModel = .init(
            userID: viewModel.userID,
            user: viewModel.creator
          )
          router.path.append(userViewModel)
        }
      
      speakersView
      
      let url: URL = .init(string: "https://twitter.com/i/spaces/\(viewModel.space.id)")!
      
      Link("Open Space", destination: url)
        .padding()
        .buttonStyle(.bordered)
    }
  }
  
  var body: some View {
    let spaceTweetsViewModel: SpaceTweetsViewModel = .init(
      userID: viewModel.userID,
      spaceID: viewModel.space.id
    )
    
    TweetsView(viewModel: spaceTweetsViewModel) {
      spaceInfoView
    }
  }
}
