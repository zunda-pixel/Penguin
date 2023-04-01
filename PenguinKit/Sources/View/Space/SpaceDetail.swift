//
//  SpaceDetail.swift
//

import SwiftUI

struct SpaceDetail: View {
  @StateObject var viewModel: SpaceDetailViewModel
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
      if let title = viewModel.space.title {  // アカウントが非公開だとタイトルは取得できない
        Text(title)
          .font(.title)
      }

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

struct SpaceDetail_Preview: PreviewProvider {
  static var previews: some View {
    SpaceDetail(
      viewModel: .init(
        userID: "userID",
        space: .init(id: "id", state: .all, creatorID: "creatorID", speakerIDs: []),
        creator: .init(
          id: "id", name: "name", userName: "userName",
          profileImageURL: URL(
            string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")!
        ),
        speakers: [
          .init(
            id: "id1", name: "name", userName: "userName",
            profileImageURL: URL(
              string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg"
            )!)
        ])
    ).spaceInfoView
  }
}
