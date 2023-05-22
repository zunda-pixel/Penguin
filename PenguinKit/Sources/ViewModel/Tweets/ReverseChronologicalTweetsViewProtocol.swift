//
//  ReverseChronologicalTweetsViewProtocol.swift
//

import CoreData
import Foundation
import RegexBuilder
import Sweet

protocol ReverseChronologicalTweetsViewProtocol: ObservableObject {
  var userID: String { get }
  var errorHandle: ErrorHandle? { get set }
  var backgroundContext: NSManagedObjectContext { get }
  var reply: Reply? { get set }
  var timelines: [Timeline] { get set }
  func addResponse(response: Sweet.TweetsResponse) throws
  func addTimelines(_ ids: [String]) throws
  func containsTimelineDataBase(tweetID: String) throws -> Bool
  func setTimelines() async
  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async
  func getTweet(_ tweetID: String) -> Tweet?
  func getUser(_ userID: String) -> User?
  func getPlaces(_ placeIDs: [String]) -> [Place]
  func getPolls(_ pollIDs: [String]) -> [Poll]
  func getMedias(_ mediaIDs: [String]) -> [Media]
}

extension ReverseChronologicalTweetsViewProtocol {
  func getTweet(_ tweetID: String) -> Tweet? {
    let request = Tweet.fetchRequest()
    request.predicate = .init(format: "id = %@", tweetID)
    request.fetchLimit = 1

    let tweets = try! backgroundContext.fetch(request)

    return tweets.first
  }

  func getPlaces(_ placeIDs: [String]) -> [Place] {
    let request = Place.fetchRequest()
    request.predicate = .init(format: "id IN %@", placeIDs)
    request.fetchLimit = placeIDs.count

    return try! backgroundContext.fetch(request)
  }

  func getPolls(_ pollIDs: [String]) -> [Poll] {
    let request = Poll.fetchRequest()
    request.predicate = .init(format: "id IN %@", pollIDs)
    request.fetchLimit = pollIDs.count

    return try! backgroundContext.fetch(request)
  }

  func getMedias(_ mediaIDs: [String]) -> [Media] {
    let request = Media.fetchRequest()
    request.predicate = .init(format: "key IN %@", mediaIDs)
    request.fetchLimit = mediaIDs.count

    return try! backgroundContext.fetch(request)
  }
  
  func getUser(_ userID: String) -> User? {
    let request = User.fetchRequest()
    request.predicate = .init(format: "id = %@", userID)
    request.fetchLimit = 1

    let users = try! backgroundContext.fetch(request)

    return users.first
  }
  
  func addResponse(response: Sweet.TweetsResponse) throws {
    let tweets = response.tweets + response.relatedTweets

    if !tweets.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Tweet.entity(),
        objects: tweets.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.users.isEmpty {
      let request = NSBatchInsertRequest(
        entity: User.entity(),
        objects: response.users.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.medias.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Media.entity(),
        objects: response.medias.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.polls.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Poll.entity(),
        objects: response.polls.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.places.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Place.entity(),
        objects: response.places.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }
    
    try backgroundContext.save()
        
    let decoder = JSONDecoder.twitter
    
    for tweet in response.tweets {
      let tweetCell = TweetCell(context: backgroundContext)
      
      let tweetContent = TweetContent(context: backgroundContext)
      tweetContent.tweet = getTweet(tweet.id)!
      tweetContent.author = getUser(tweet.authorID!)!
      tweetCell.tweetContent = tweetContent
      
      let retweetID = tweet.referencedTweets.first { $0.type == .retweeted }?.id
      let retweet = retweetID.map { getTweet($0)! }
      let retweetAuthor = retweet.map { getUser($0.authorID!)! }
      
      if let retweet, let retweetAuthor {
        let retweetContent = TweetContent(context: backgroundContext)
        retweetContent.tweet = retweet
        retweetContent.author = retweetAuthor
        tweetCell.retweet = retweetContent
      }
      
      let quotedID: String?
      
      if let quoted = tweet.referencedTweets.first(where: { $0.type == .quoted }) {
        quotedID = quoted.id
      } else {
        let retweetReferenced = retweet?.referencedTweets.map {
          try! decoder.decode([Sweet.ReferencedTweetModel].self, from: $0)
        }
        quotedID = retweetReferenced?.first { $0.type == .quoted }?.id
      }
      
      if let quotedID {
        let quoted = QuotedTweetContent(context: backgroundContext)
        
        let quotedTweetContent = TweetContent(context: backgroundContext)
        quotedTweetContent.tweet = getTweet(quotedID)!
        quotedTweetContent.author = getUser(quotedTweetContent.tweet!.authorID!)!
        quoted.tweetContent = quotedTweetContent

        let quotedReferenced = try! decoder.decode(
          [Sweet.ReferencedTweetModel].self,
          from: quotedTweetContent.tweet!.referencedTweets!
        )
        
        if let quotedID = quotedReferenced.first(where: { $0.type == .quoted })?.id {
          if let tweet = getTweet(quotedID) {
            let quotedContent = TweetContent(context: backgroundContext)
            quotedContent.tweet = tweet
            quotedContent.author = getUser(tweet.authorID!)!
            quoted.quoted = quotedContent
          }
        }
        
        tweetCell.quoted = quoted
      }
      
      let tweets = [
        tweetCell.tweetContent?.tweet,
        tweetCell.retweet?.tweet,
        tweetCell.quoted?.tweetContent?.tweet,
        tweetCell.quoted?.quoted?.tweet
      ].compacted()
      
      let attachments = tweets.compactMap(\.attachments).compactMap {
        return try! decoder.decode(Sweet.AttachmentsModel.self, from: $0)
      }
      
      let mediaKeys = attachments.flatMap { $0.mediaKeys }
      tweetCell.medias = Set(getMedias(Array(mediaKeys.uniqued()))) as NSSet
      let pollIDs = attachments.compactMap { $0.pollID }
      tweetCell.polls = Set(getPolls(Array(pollIDs.uniqued()))) as NSSet
      
      let placeIDs = tweets.compactMap(\.geo).compactMap {
        let geo = try! decoder.decode(Sweet.SimpleGeoModel.self, from: $0)
        return geo.placeID
      }
      
      tweetCell.places = Set(getPlaces(Array(placeIDs.uniqued()))) as NSSet
    }
  }

  func addTimelines(_ ids: [String]) throws {
    let request = NSBatchInsertRequest(
      entity: Timeline.entity(),
      objects: ids.map { ["tweetID": $0, "ownerID": userID] }
    )

    try backgroundContext.execute(request)
  }

  func containsTimelineDataBase(tweetID: String) throws -> Bool {
    let request = Timeline.fetchRequest()
    request.predicate = .init(format: "tweetID = %@ AND ownerID = %@", tweetID, userID)
    request.fetchLimit = 1
    let tweetCount = try self.backgroundContext.count(for: request)

    return tweetCount > 0
  }

  @MainActor
  func setTimelines() async {
    let request = Timeline.fetchRequest()
    request.predicate = .init(format: "ownerID = %@", userID)
    request.sortDescriptors = [.init(keyPath: \Timeline.tweetID, ascending: false)]
    do {
      timelines = try await backgroundContext.perform {
        try self.backgroundContext.fetch(request)
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  @MainActor
  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async {
    do {
      let response = try await Sweet(userID: userID).reverseChronological(
        userID: userID,
        untilID: lastTweetID,
        paginationToken: paginationToken
      )

      let quotedQuotedTweetIDs = response.relatedTweets.flatMap(\.referencedTweets).map(\.id)

      let ids = quotedQuotedTweetIDs + response.relatedTweets.map(\.id)

      let responses = try await Sweet(userID: userID).tweets(ids: Set(ids))

      try await backgroundContext.perform {
        for response in responses {
          try self.addResponse(response: response)
        }

        try self.addResponse(response: response)
      }

      let containsTweet: Bool = try await backgroundContext.perform {
        guard let lastTweetID = response.tweets.last?.id else { return true }

        return try self.containsTimelineDataBase(tweetID: lastTweetID)
      }

      try await backgroundContext.perform {
        try self.addTimelines(response.tweets.map(\.id))
      }

      if let paginationToken = response.meta?.nextToken, !containsTweet {
        await fetchTweets(last: nil, paginationToken: paginationToken)
      }

      await setTimelines()
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
