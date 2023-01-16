//
//  OnlineTweetDetailView.swift
//

import SwiftUI

struct OnlineTweetDetailView: View {
  @ObservedObject var viewModel: OnlineTweetDetailViewModel
  
  @ViewBuilder
  func cellView(viewModel: TweetCellViewModel) -> some View {
    VStack {
      TweetCellView(viewModel: viewModel)
      
      if self.viewModel.tweetID == viewModel.tweetText.id {
        TweetToolBar(
          viewModel: .init(
            userID: viewModel.userID,
            tweet: viewModel.tweet,
            user: viewModel.author
          )
        )
        .labelStyle(.iconOnly)
        
        Divider()
        
        HStack {
          Text(
            viewModel.tweet.createdAt!.formatted(date: .abbreviated, time: .standard)
          )
          
          // sourceがnilの場合を考慮(APIの仕様変更の可能性があるため)
          if let source = viewModel.tweet.source {
            Text("via \(source)")
          }
        }
        
        Divider()
        
        TweetDetailInformation(
          userID: viewModel.userID,
          tweetID: viewModel.tweet.id,
          metrics: viewModel.tweet.publicMetrics!
        )
      }
    }
  }
  
  var body: some View {
    ScrollView {
      Group {
        if let tweetNode = viewModel.tweetNode {
          NodeView([tweetNode], children: \.children) { child, depth in
            let viewModel = self.viewModel.getTweetCellViewModel(child.id)
            let depth = depth < 3 ? depth : 3
            cellView(viewModel: viewModel)
              .padding(.leading, CGFloat(depth) * 10)
            Divider()
          }
        } else {
          ProgressView()
        }
      }
      .scrollContentAttribute()
    }
    .scrollViewAttitude()
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.fetchTweets(first: nil, last: nil)
    }
  }
}
