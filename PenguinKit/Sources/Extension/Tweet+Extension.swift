//
//  Tweet+Extension.swift
//

import Foundation
import Sweet

extension Tweet {
  func setTweetModel(_ tweet: Sweet.TweetModel) {
    self.id = tweet.id
    self.text = tweet.text
    self.authorID = tweet.authorID
    self.lang = tweet.lang
    self.createdAt = tweet.createdAt
    self.replySetting = tweet.replySetting?.rawValue
    self.conversationID = tweet.conversationID
    self.source = tweet.source
    self.replyUserID = tweet.replyUserID

    let encoder = JSONEncoder.twitter
    self.geo = try! encoder.encodeIfExists(tweet.geo)
    self.entities = try! encoder.encodeIfExists(tweet.entity)
    self.attachments = try! encoder.encodeIfExists(tweet.attachments)
    self.contextAnnotations = try! encoder.encode(tweet.contextAnnotations)
    self.organicMetrics = try! encoder.encodeIfExists(tweet.organicMetrics)
    self.privateMetrics = try! encoder.encodeIfExists(tweet.privateMetrics)
    self.promotedMetrics = try! encoder.encodeIfExists(tweet.promotedMetrics)
    self.publicMetrics = try! encoder.encodeIfExists(tweet.publicMetrics)
    self.referencedTweets = try! encoder.encode(tweet.referencedTweets)
    self.withheld = try! encoder.encodeIfExists(tweet.withheld)
    self.editControl = try! encoder.encodeIfExists(tweet.editControl)
    self.editHistoryTweetIDs = try! encoder.encode(tweet.editHistoryTweetIDs)
  }
}

extension Sweet.TweetModel {
  init(tweet: Tweet) {
    let decoder = JSONDecoder.twitter

    let geo = try! decoder.decodeIfExists(
      Sweet.SimpleGeoModel.self,
      from: tweet.geo
    )

    let publicMetics = try! decoder.decodeIfExists(
      Sweet.TweetPublicMetrics.self,
      from: tweet.publicMetrics
    )

    let privateMetrics = try! decoder.decodeIfExists(
      Sweet.PrivateMetrics.self,
      from: tweet.privateMetrics
    )

    let organicMetrics = try! decoder.decodeIfExists(
      Sweet.OrganicMetrics.self,
      from: tweet.organicMetrics
    )

    let promotedMetrics = try! decoder.decodeIfExists(
      Sweet.PromotedMetrics.self,
      from: tweet.promotedMetrics
    )

    let attachments = try! decoder.decodeIfExists(
      Sweet.AttachmentsModel.self,
      from: tweet.attachments
    )
    let withheld = try! decoder.decodeIfExists(
      Sweet.WithheldModel.self,
      from: tweet.withheld
    )

    let contextAnnotations = try! decoder.decodeIfExists(
      [Sweet.ContextAnnotationModel].self,
      from: tweet.contextAnnotations
    )

    let entity = try! decoder.decodeIfExists(
      Sweet.TweetEntityModel.self,
      from: tweet.entities
    )

    let referencedTweets = try! decoder.decodeIfExists(
      [Sweet.ReferencedTweetModel].self,
      from: tweet.referencedTweets
    )

    let replySettings = tweet.replySetting.map { Sweet.ReplySetting(rawValue: $0)! }

    let editControl = try! decoder.decodeIfExists(
      Sweet.EditControl.self,
      from: tweet.editControl
    )

    let editHistoryTweetIDs = try! decoder.decodeIfExists(
      [String].self,
      from: tweet.editHistoryTweetIDs
    )

    self.init(
      id: tweet.id!,
      text: tweet.text!,
      authorID: tweet.authorID,
      lang: tweet.lang,
      replySetting: replySettings,
      createdAt: tweet.createdAt,
      source: tweet.source,
      sensitive: tweet.sensitive,
      conversationID: tweet.conversationID,
      replyUserID: tweet.replyUserID,
      geo: geo,
      publicMetrics: publicMetics,
      organicMetrics: organicMetrics,
      privateMetrics: privateMetrics,
      attachments: attachments,
      promotedMetrics: promotedMetrics,
      withheld: withheld,
      contextAnnotations: contextAnnotations ?? [],
      entity: entity,
      referencedTweets: referencedTweets ?? [],
      editHistoryTweetIDs: editHistoryTweetIDs ?? [],
      editControl: editControl
    )
  }
}
