//
//  TweetCellViewProvider.swift
//

import CoreData
import Foundation
import Sweet

struct TweetCellViewProvider {
  let backgroundContext: NSManagedObjectContext

  init() {
    backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
  }
  
  func getUsers(screenIDs: [String]) -> [Sweet.UserModel] {
    let request = User.fetchRequest()
    request.predicate = .init(format: "userName IN %@", screenIDs)
    request.fetchLimit = screenIDs.count

    let users = try! backgroundContext.fetch(request)

    return users.map { .init(user: $0) }
  }

  func reply(viewModel: TweetCellViewModel) async -> Reply {
    let mentions = viewModel.tweet.entity?.mentions ?? []
    let userNames = mentions.map(\.userName)

    let users: [Sweet.UserModel] = await backgroundContext.perform {
      getUsers(screenIDs: userNames)
    }

    let userModels: [Sweet.UserModel] = users + [viewModel.author]

    let tweetContent = TweetContentModel(
      tweet: viewModel.tweetText, author: viewModel.tweetAuthor)

    return Reply(
      tweetContent: tweetContent,
      replyUsers: userModels.uniqued(by: \.id)
    )
  }

  func getTweetCellViewModel(userID: String, tweetID: String) async -> TweetCellViewModel {
    return await backgroundContext.perform {
      let request = TweetCell.fetchRequest()
      let tweetCell = try! backgroundContext.fetch(request).first { ($0 as TweetCell).tweetContent!.tweet!.id! == tweetID }!

      let viewModel: TweetCellViewModel = .init(
        userID: userID,
        tweet: Sweet.TweetModel(tweet: tweetCell.tweetContent!.tweet!),
        author: Sweet.UserModel(user: tweetCell.tweetContent!.author!),
        retweet: tweetCell.retweet.map {
          TweetContentModel(
            tweet: Sweet.TweetModel(tweet: $0.tweet!),
            author: Sweet.UserModel(user: $0.author!)
          )
        },
        quoted: tweetCell.quoted.map {
          QuotedTweetModel(
            tweetContent: TweetContentModel(
              tweet: Sweet.TweetModel(tweet: $0.tweetContent!.tweet!),
              author: Sweet.UserModel(user: $0.tweetContent!.author!)
            ),
            quoted: $0.quoted.map {
              TweetContentModel(
                tweet: Sweet.TweetModel(tweet: $0.tweet!),
                author: Sweet.UserModel(user: $0.author!)
              )
            }
          )
        },
        medias: tweetCell.medias!.map { Sweet.MediaModel(media: $0 as! Media) },
        polls: tweetCell.polls!.map { Sweet.PollModel(poll: $0 as! Poll) },
        places: tweetCell.places!.map { Sweet.PlaceModel(place: $0 as! Place) }
      )

      return viewModel
    }
  }
}
