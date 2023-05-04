//
// OnlineUserDetailView.swift
//

import SwiftUI
import Sweet

struct OnlineUserDetailView: View {
  @StateObject var viewModel: OnlineUserDetailViewModel
  @State var loadingUser = false
  
  func fetchUser() async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }
    
    await viewModel.fetchUser()
  }

  var body: some View {
    VStack {
      if let user = viewModel.targetUser {
        let viewModel: UserDetailViewModel = .init(userID: viewModel.userID, user: user)
        
        UserDetailView(viewModel: viewModel)
      } else {
        placeHolderView
      }
    }
    .task {
      await fetchUser()
    }
  }
  
  var placeHolderView: some View {
    List {
      VStack {
        let user = Sweet.UserModel.placeHolder
        ProfileImageView(url: user.profileImageURL!)
          .frame(width: 100, height: 100)
        UserProfileView(viewModel: .init(user: user))
        
        VStack {
          let buttonWidth: CGFloat = 200
          
          Button { } label: {
            Label("DirectMessage", systemImage: "envelope.fill")
              .frame(maxWidth: buttonWidth * 2)
          }

          HStack {
            Button { } label: {
              Label("FOLLOWERS", systemImage: "figure.wave")
                .frame(maxWidth: buttonWidth)
            }
            Button { } label: {
              Label("FOLLOWING", systemImage: "figure.walk")
                .frame(maxWidth: buttonWidth)
            }
          }
          HStack {
            Button { } label: {
              Label("Like", systemImage: "heart")
                .frame(maxWidth: buttonWidth)
            }
            Button { } label: {
              Label("List", systemImage: "list.dash.header.rectangle")
                .frame(maxWidth: buttonWidth)
            }
          }
        }
        
        Divider()
      }
        .padding()
        .listRowInsets(EdgeInsets())
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        .listRowSeparator(.hidden)
      
      ForEach(0..<100) { _ in
        VStack {
          TweetCellView(viewModel: TweetCellViewModel.placeHolder)
            .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))
          Divider()
        }
        .listRowInsets(EdgeInsets())
      }
      .listContentAttribute()
      .listRowSeparator(.hidden)
    }
    .listStyle(.inset)
    .redacted(reason: .placeholder)
  }
}
