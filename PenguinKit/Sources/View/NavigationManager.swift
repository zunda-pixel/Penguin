//
//  NavigationManager.swift
//

import SwiftUI

extension View {
  func navigationDestination() -> some View {
    self.modifier(NavigationManager())
  }
}

struct NavigationManager: ViewModifier {
  func body(content: Content) -> some View {
    content
      .navigationDestination(for: DirectMessageDetailViewModel.self) { viewModel in
        DirectMessageDetailView(viewModel: viewModel)
          .navigationTitle("DirectMessage")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: TweetDetailViewModel.self) { viewModel in
        TweetDetailView(viewModel: viewModel)
          .navigationTitle("Detail")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: UserTweetsViewModel.self) { viewModel in
        TweetsView(viewModel: viewModel)
          .navigationTitle("All Tweets")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: UserDetailViewModel.self) { viewModel in
        UserDetailView(viewModel: viewModel)
          .navigationTitle("@\(viewModel.user.userName)")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: FollowingUserViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Following")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: FollowerUserViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Follower")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: QuoteTweetsViewModel.self) { viewModel in
        TweetsView(viewModel: viewModel)
          .navigationTitle("Quote Tweet")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: LikeUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Like")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: RetweetUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Retweet")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: LikesViewModel.self) { viewModel in
        TweetsView(viewModel: viewModel)
          .navigationTitle("Likes")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: UserMentionsViewModel.self) { viewModel in
        TweetsView(viewModel: viewModel)
          .navigationTitle("Mentions")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: UserListViewModel.self) { viewModel in
        UserListsView(viewModel: viewModel)
          .navigationTitle("List")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: ListDetailViewModel.self) { viewModel in
        ListDetailView(viewModel: viewModel)
          .navigationTitle(viewModel.list.name)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: ListFollowersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Follower")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: ListMembersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("List Member")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: OnlineUserDetailViewModel.self) { viewModel in
        OnlineUserDetailView(viewModel: viewModel)
          .navigationTitle("Detail")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: AccountDetailViewModel.self) { viewModel in
        AccountDetailView(viewModel: viewModel)
          .navigationTitle("@\(viewModel.user.userName)")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: MutingUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Mute")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: BlockingUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle("Block")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: SpaceDetailViewModel.self) { viewModel in
        SpaceDetail(viewModel: viewModel)
          .navigationTitle("Space")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: SearchTweetsViewModel.self) { viewModel in
        TweetsView(viewModel: viewModel)
          .navigationTitle(viewModel.query)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
      .navigationDestination(for: SearchUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel)
          .navigationTitle(viewModel.query)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarAttribute()
      }
  }
}
