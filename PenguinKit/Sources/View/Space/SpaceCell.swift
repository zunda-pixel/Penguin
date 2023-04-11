//
//  SearchSpacesView.swift
//

import Sweet
import SwiftUI

struct SpaceCell: View {
  @StateObject var viewModel: SpaceDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(url: viewModel.creator.profileImageURL!)
        .frame(width: 50, height: 50)
        .padding(.trailing)

      VStack(alignment: .leading) {
        HStack {
          (Text(viewModel.creator.name)
            + Text(" @\(viewModel.creator.userName)").foregroundColor(.secondary))
            .lineLimit(1)

          Spacer()

          let displayDate = viewModel.space.startedAt ?? viewModel.space.scheduledStart!

          TimelineView(.periodic(from: .now, by: 1)) { _ in
            Text(displayDate, format: .relative(presentation: .named))
          }
        }

        if let title = viewModel.space.title {
          Text(title)
            .lineLimit(nil)
        }

        HStack {
          Spacer()

          ForEach(viewModel.speakers.prefix(4)) { speaker in
            ProfileImageView(url: speaker.profileImageURL!)
              .frame(width: 15, height: 15)
          }

          if !viewModel.speakers.isEmpty {
            Text("\(viewModel.speakers.count) Listening")
          }
        }
      }
    }
    .padding()
    .background(Color.random.opacity(0.5))
    .cornerRadius(24)
    .onTapGesture {
      router.path.append(viewModel)
    }
  }
}

struct SpaceCell_Preview: PreviewProvider {
  static var previews: some View {
    SpaceCell(
      viewModel: .init(
        userID: "userID",
        space: .init(
          id: "id", state: .all, creatorID: "creatorID",
          title:
            "kljaakjfalsdjfa;sldkfja;lsdkjf;als\nkdjfasdfasdfasfalkdjfa;lskdjf;laksjdf;lakjsd;flkajs;dlfkja;slkdfj;alksjdf;lakjdf;lkajsd;lfkja;ljk",
          startedAt: .now, speakerIDs: []),
        creator: .init(
          id: "id", name: "name", userName: "userName",
          profileImageURL: URL(
            string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")),
        speakers: []))
  }
}
