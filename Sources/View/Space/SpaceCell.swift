//
//  SearchSpacesView.swift
//

import Sweet
import SwiftUI

struct SpaceCell: View {
  let userID: String
  let space: Sweet.SpaceModel
  let creator: Sweet.UserModel
  let speakers: [Sweet.UserModel]

  @EnvironmentObject var router: NavigationPathRouter

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(url: creator.profileImageURL!)
        .frame(width: 50, height: 50)
        .padding(.trailing)

      VStack {
        HStack {
          (Text(creator.name) + Text(" @\(creator.userName)").foregroundColor(.secondary))
            .lineLimit(1)

          Spacer()

          let displayDate = space.startedAt ?? space.scheduledStart!

          TimelineView(.periodic(from: .now, by: 1)) { _ in
            Text(displayDate, format: .relative(presentation: .named))
          }
        }

        if let title = space.title {
          HStack {
            Text(title)
              .lineLimit(nil)
            Spacer()
          }
        }

        HStack {
          Spacer()
          
          ForEach(speakers.prefix(4)) { speaker in
            ProfileImageView(url: speaker.profileImageURL!)
              .frame(width: 15, height: 15)
          }

          if !speakers.isEmpty {
            Text("\(speakers.count) Listening")
          }
        }
      }
    }
    .padding()
    .background(Color.random.opacity(0.5))
    .cornerRadius(24)
    .onTapGesture {
      let spaceDetailViewModel: SpaceDetailViewModel = .init(
        userID: userID,
        space: space,
        creator: creator,
        speakers: speakers
      )
      router.path.append(spaceDetailViewModel)
    }
  }
}
