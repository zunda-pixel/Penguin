//
//  ListCellView.swift
//

import Sweet
import SwiftUI

struct ListCellView: View {
  let list: Sweet.ListModel
  let owner: Sweet.UserModel
  let userID: String

  @EnvironmentObject var router: NavigationPathRouter

  var body: some View {
    HStack {
      ProfileImageView(url: owner.profileImageURL!)
        .frame(width: 50, height: 50)
        .onTapGesture {
          let userViewModel: UserDetailViewModel = .init(userID: userID, user: owner)
          router.path.append(userViewModel)
        }

      VStack(alignment: .leading) {
        HStack {
          Text(list.name)
            .font(.title2)

          if list.isPrivate! {
            Image(systemName: "key")
          }

          Text(list.description!)
            .foregroundColor(.secondary)
        }
        .lineLimit(1)

        Text("\(owner.name) @\(owner.userName)")
          .lineLimit(1)
      }

      Spacer()
    }
    .contentShape(Rectangle())
    .onTapGesture {
      let listDetailViewModel: ListDetailViewModel = .init(userID: userID, list: list)
      router.path.append(listDetailViewModel)
    }
  }
}

struct ListCellView_Preview: PreviewProvider {
  static var previews: some View {
    ListCellView(list: .init(id: "id", name: "name", description: "description", isPrivate: true), owner: .init(id: "id", name: "name", userName: "userName", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")!), userID: "userID")
  }
}
