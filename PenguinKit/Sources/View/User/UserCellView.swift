//
//  UserCellView.swift
//

import Sweet
import SwiftUI

struct UserCellView: View {
  @StateObject var viewModel: UserCellViewModel

  @EnvironmentObject var router: NavigationPathRouter

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(url: viewModel.user.profileImageURL!)
        .frame(width: 60, height: 60)
      VStack(alignment: .leading) {
        HStack(alignment: .center) {
          VStack(alignment: .leading) {
            HStack {
              Text(viewModel.user.name)
              if viewModel.user.verified! {
                Image.verifiedMark
              }
            }

            Text("@\(viewModel.user.userName)")
              .foregroundColor(.secondary)
          }
          Spacer()

          if viewModel.ownerID != viewModel.user.id {
            Button {
              Task {
                await viewModel.follow()
              }
            } label: {
              Text("Follow")
                .padding(.horizontal, 10)
            }
            .clipShape(Capsule())
            .buttonStyle(.bordered)
          }
        }

        Text(viewModel.user.description!)
      }
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .contentShape(Rectangle())
    .onTapGesture {
      let userViewModel: UserDetailViewModel = .init(
        userID: viewModel.ownerID,
        user: viewModel.user
      )
      router.path.append(userViewModel)
    }
  }
}

struct UserCellView_Preview: PreviewProvider {
  static var previews: some View {
    let viewModel: UserCellViewModel = UserCellViewModel(
      ownerID: "ownerID",
      user: .placeHolder
    )
    UserCellView(viewModel: viewModel)
  }
}
