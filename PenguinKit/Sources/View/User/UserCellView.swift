//
//  UserCellView.swift
//

import Sweet
import SwiftUI

struct UserCellView: View {
  let ownerID: String
  let user: Sweet.UserModel

  @EnvironmentObject var router: NavigationPathRouter

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(url: user.profileImageURL!)
        .frame(width: 60, height: 60)
      VStack(alignment: .leading) {
        HStack(alignment: .center) {
          VStack(alignment: .leading) {
            HStack {
              Text(user.userName)
              if user.verified! {
                Image.verifiedMark
              }
            }

            Text("@\(user.name)")
              .foregroundColor(.secondary)
          }
          Spacer()

          if ownerID != user.id {
            Button {
              print("Follow")
            } label: {
              Text("Follow")
                .padding(.horizontal, 10)
            }
            .clipShape(Capsule())
            .buttonStyle(.bordered)
          }
        }

        Text(user.description!)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      let userViewModel: UserDetailViewModel = .init(userID: ownerID, user: user)
      router.path.append(userViewModel)
    }
  }
}

struct UserCellView_Preview: PreviewProvider {
  static var previews: some View {
    UserCellView(ownerID: "ownerID", user: .init(id: "id", name: "name", userName: "userName", verified: true, profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")!, description: "description"))
  }
}
