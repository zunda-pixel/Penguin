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

      VStack {
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
          HStack {
            Text(title)
              .lineLimit(nil)
            Spacer()
          }
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
