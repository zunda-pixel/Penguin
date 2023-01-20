//
// OGPCardView.swift
//

import Kingfisher
import SwiftUI
import Sweet

struct OGPCardView: View {
  let urlModel: Sweet.URLModel

  @Environment(\.openURL) var openURL
  @Environment(\.settings) var settings

  var body: some View {
    VStack {
      let padding: CGFloat = 20

      VStack(alignment: .leading) {
        let imageURL = urlModel.images.max { $0.size.height * $0.size.width < $1.size.height * $1.size.width }
        
        KFImage(imageURL!.url)
          .resizable()
          .scaledToFit()
        
        VStack(alignment: .leading) {
          Text(urlModel.displayURL!)
            .foregroundStyle(settings.colorType.colorSet.tintColor)

          Text(urlModel.title!)
            .lineLimit(2)

          if let description = urlModel.description {
            Text(description)
              .foregroundStyle(.secondary)
              .font(.caption)
              .lineLimit(2)
          }
        }
        .padding(.horizontal, padding)
      }
      .clipShape(RoundedRectangle(cornerSize: .init(width: padding, height: padding)))
      .contentShape(RoundedRectangle(cornerSize: .init(width: padding, height: padding)))
      .overlay {
        RoundedRectangle(cornerSize: .init(width: padding, height: padding))
          .stroke(.secondary)
      }
      .onTapGesture {
        openURL(urlModel.url)
      }
    }
  }
}

struct OGPCardView_Previews: PreviewProvider {
  static var previews: some View {
    
    
    let urlModel: Sweet.URLModel = .init(start: 0, end: 0, url: .init(string: "https://cssnite.doorkeeper.jp/events/141697")!, expandedURL: "", displayURL: "displayURL", images: [
      .init(url: .init(string: "https://doorkeeper.jp/rails/active_storage/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBd2txQlE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--8f7f15635de87fd0b7b3b249dd872d9e75eb883d/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFMb0F6QT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--91839951a073aea8822f6907dc8d81559a890706/cssnite-20221125-CodersHigh.png")!, size: .zero)
      
    ], title: "Title", description: "Description")

    OGPCardView(urlModel: urlModel)
  }
}
