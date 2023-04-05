//
//  PlaceHolderTweetCellView.swift
//

import SwiftUI

struct PlaceHolderTweetCellView: View {
  @State var viewModel: TweetCellViewModel?
  
  var body: some View {
    if let viewModel {
      TweetCellView(viewModel: viewModel)
    } else {
      TweetCellView(viewModel: TweetCellViewModel.placeHolder)
        .redacted(reason: .placeholder)
    }
  }
}

struct PlaceHolderTweetCellView_Preview: PreviewProvider {
  static var previews: some View {
    PlaceHolderTweetCellView()
      .padding()
  }
}
