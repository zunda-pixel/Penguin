//
//  SelectReplyUsersView.swift
//

import SwiftUI
import Sweet

struct SelectReplyUsersView: View {
  let tweetOwnerID: String
  let allUsers: [Sweet.UserModel]
  @Binding var selection: Set<String>
  
  init(tweetOwnerID: String, allUsers: [Sweet.UserModel], selection: Binding<Set<String>>) {
    self.tweetOwnerID = tweetOwnerID
    self.allUsers = allUsers
    self._selection = selection
  }
  
  func userCell(user: Sweet.UserModel) -> some View {
    Label {
      Text(user.userName)
    } icon: {
      ProfileImageView(url: user.profileImageURL!)
        .frame(width: 40, height: 40)
    }
    .tag(user.id)
  }
  
  var body: some View {
    NavigationStack {
      List(selection: $selection) {
        let owner = allUsers.first { $0.id == tweetOwnerID }!
        userCell(user: owner)
        
        let otherUsers = allUsers.filter { $0.id != tweetOwnerID }
        
        if !otherUsers.isEmpty {
          Section {
            ForEach(otherUsers) { user in
              userCell(user: user)
            }
          } header: {
            HStack {
              Text("Others in this conversation")
                 
              Spacer()
              
              Toggle("Select/Deselect All",isOn: .init(
                get: {
                  selection.count == allUsers.count
                },
                set: { isOn in
                  if isOn {
                    selection = Set(allUsers.map(\.id))
                  } else {
                    selection = []
                  }
                })
              )
              .labelsHidden()
            }
          }
        }
      }
      .environment(\.editMode, .constant(.active))
      // TODO List(selection)内でdisabledが使用できれば以下のコードは不要
      .onChange(of: selection) { _ in
        selection.insert(tweetOwnerID)
      }
      .navigationTitle("Replying to")
    }
  }
}

struct SelectReplyUsersView_Preview: PreviewProvider {
  struct Preview: View {
    @State var isPresented = false
    
    let users: [Sweet.UserModel] = [
      .init(id: "1", name: "name1", userName: "name1", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1605096515281641472/XDbwQ_h6_400x400.jpg")),
      .init(id: "2", name: "name2", userName: "name2", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1605096515281641472/XDbwQ_h6_400x400.jpg")),
      .init(id: "3", name: "name3", userName: "name3", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1605096515281641472/XDbwQ_h6_400x400.jpg")),
      .init(id: "4", name: "name4", userName: "name4", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1605096515281641472/XDbwQ_h6_400x400.jpg")),
      .init(id: "5", name: "name5", userName: "name5", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1605096515281641472/XDbwQ_h6_400x400.jpg")),
      .init(id: "6", name: "name6", userName: "name6", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1605096515281641472/XDbwQ_h6_400x400.jpg")),
    ]
    
    @State var selection: Set<String> = ["1"]
    
    
    var body: some View {
      Button {
        isPresented.toggle()
      } label: {
        HStack {
          ForEach(users.filter { selection.contains($0.id) }) { user in
            Text(user.userName)
          }
        }
      }
      .sheet(isPresented: $isPresented) {
        SelectReplyUsersView(tweetOwnerID: "1", allUsers: users, selection: $selection)
      }
    }
  }
  
  static var previews: some View {
    Preview()
  }
}
