//
//  UserToolMenu.swift
//

import Sweet
import SwiftUI

struct UserToolMenu: View {
  let fromUserID: String
  let toUserID: String

  @State var errorHandle: ErrorHandle?

  var body: some View {
    Menu {
      FollowButton(fromUserID: fromUserID, toUserID: toUserID, errorHandle: $errorHandle)
      UnFollowButton(fromUserID: fromUserID, toUserID: toUserID, errorHandle: $errorHandle)

      BlockButton(fromUserID: fromUserID, toUserID: toUserID, errorHandle: $errorHandle)
      UnBlockButton(fromUserID: fromUserID, toUserID: toUserID, errorHandle: $errorHandle)

      MuteButton(fromUserID: fromUserID, toUserID: toUserID, errorHandle: $errorHandle)
      UnMuteButton(fromUserID: fromUserID, toUserID: toUserID, errorHandle: $errorHandle)
    } label: {
      Image(systemName: "ellipsis")
    }
    .alert(errorHandle: $errorHandle)
  }
}

struct UserToolMenu_Preview: PreviewProvider {
  static var previews: some View {
    UserToolMenu(fromUserID: "fromUserID", toUserID: "toUserID")
  }
}
