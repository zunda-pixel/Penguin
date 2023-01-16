//
//  TweetNode.swift
//

import Node

struct TweetNodeSource: NodeSource, Hashable {
  let id: String
  let parentID: String
}

struct TweetNode: Node, Equatable, Identifiable {
  let id: String
  var children: [TweetNode]
  typealias Source = TweetNodeSource

  init(id: String) {
    self.id = id
    self.children = []
  }

  init(id: String, children: [TweetNode] = []) {
    self.id = id
    self.children = children
  }
}
