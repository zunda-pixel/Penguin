//
//  SearchView.swift
//

import Sweet
import SwiftUI

struct SearchView: View {
  @ObservedObject var viewModel: SearchViewModel

  @StateObject var router = NavigationPathRouter()

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  enum Pages: String, CaseIterable, Identifiable {
    case user = "User"
    case tweet = "Tweet"

    var id: String { self.rawValue }
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        TextField(text: $viewModel.query) {
          Text("\(Image(systemName: "magnifyingglass")) Search Twitter")
            .foregroundColor(settings.colorType.colorSet.tintColor)
        }

        if !viewModel.query.isEmpty {
          Section {
            let tweetViewModel = SearchTweetsViewModel(
              userID: viewModel.userID,
              query: viewModel.query,
              queryBuilder: viewModel.searchSettings
            )

            NavigationLink(value: tweetViewModel) {
              Label(
                "Tweets with \"\(viewModel.query)\"", systemImage: "bubble.left"
              )
            }

            let userViewModel = SearchUsersViewModel(
              userID: viewModel.userID,
              query: viewModel.query
            )
            NavigationLink(value: userViewModel) {
              Label("Users with \"\(viewModel.query)\"", systemImage: "person")
            }
          }
        }

        Section("Tweet Filter") {
          Toggle("Exclude Retweet", isOn: $viewModel.searchSettings.excludeRetweet)

          Picker("Tweet Type", selection: $viewModel.searchSettings.tweetType) {
            ForEach(TweetType.allCases) { type in
              Text(type.rawValue)
                .tag(type)
            }
          }

          Toggle("Only Verified", isOn: $viewModel.searchSettings.onlyVerified)
          Toggle("Only Has Links", isOn: $viewModel.searchSettings.hasLink)
          Toggle("Only Has Video", isOn: $viewModel.searchSettings.hasVideo)
          Toggle("Only Has Image", isOn: $viewModel.searchSettings.hashImage)
          Toggle("Only Has Media", isOn: $viewModel.searchSettings.hasMedia)
          Toggle("Only Has Mention", isOn: $viewModel.searchSettings.hasMentions)
          Toggle("Only Has Hashtag", isOn: $viewModel.searchSettings.hasHashTag)
        }
      }
      .navigationBarAttribute()
      .scrollViewAttitude()
      .scrollDismissesKeyboard(.immediately)
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination()
      .toolbar {
        TopToolBar(currentUser: $currentUser, loginUsers: $loginUsers, settings: $settings)
      }
    }
    .environmentObject(router)
  }
}
