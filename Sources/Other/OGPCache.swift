//
// OGPCache.swift
//

import Cache
import Foundation
import HTMLString
import OpenGraph
import Sweet

struct OGPValue: Codable {
  let title: String?
  let imageURL: URL
  let description: String?
}

struct OGPCache {
  let storage: Storage<URL, OGPValue>

  init() throws {
    let disConfig = DiskConfig(name: "OGP")
    let memoryConfig = MemoryConfig()

    self.storage = try Storage<URL, OGPValue>(
      diskConfig: disConfig,
      memoryConfig: memoryConfig,
      transformer: TransformerFactory.forCodable(ofType: OGPValue.self)
    )
  }
}

struct OGPManager {
  static func fetchOGPData(url: URL) async throws -> OGPValue? {
    let cache = try OGPCache()

    if let ogp = try? cache.storage.object(forKey: url) {
      return ogp
    }

    let ogp = try await OpenGraph.fetch(url: url)

    guard let imageURLString = ogp[.image] else { return nil }
    let decodedURLString = imageURLString.removingHTMLEntities()
    guard let imageURL = URL(string: decodedURLString) else { return nil }

    let value = OGPValue(
      title: ogp[.title],
      imageURL: imageURL,
      description: ogp[.description]
    )

    try cache.storage.setObject(value, forKey: url)

    return value
  }

  static func fetchOGPData(urls: [URL]) async throws -> [URL: OGPValue] {
    var ogpDatas: [URL: OGPValue] = [:]

    try await withThrowingTaskGroup(of: (URL, OGPValue?).self) { group in
      for url in urls {
        group.addTask {
          return (url, try? await fetchOGPData(url: url))
        }
      }

      for try await (url, ogp) in group {
        if let ogp {
          ogpDatas[url] = ogp
        }
      }
    }

    return ogpDatas
  }

  static func fetchOGPData(tweets: [Sweet.TweetModel]) async throws -> [URL: OGPValue] {
    // if tweet has media, this tweet doesn't need ogp image
    let notMediaTweets = tweets.filter { $0.attachments?.mediaKeys.isEmpty == true }

    // if tweet has multi url, use last url and url is not "twitter.com"
    let urlModels: [Sweet.URLModel] = notMediaTweets.compactMap(\.entity).compactMap {
      $0.urls.filter { $0.url.host != "twitter.com" }.last
    }

    let urls = urlModels.compactMap { $0.expandedURL.map { URL(string: $0) } ?? $0.url }

    return try await fetchOGPData(urls: urls)
  }
}
