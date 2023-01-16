//
//  TabItem.swift
//

import Foundation

enum TabItem: String, Identifiable, CaseIterable {
  var id: String { rawValue }

  case timeline
  case list
  case search
  case space
  case bookmark
  case like
  case mention

  var title: String {
    switch self {
    case .timeline: return "Timeline"
    case .list: return "List"
    case .search: return "Search"
    case .space: return "Space"
    case .bookmark: return "Bookmark"
    case .like: return "Like"
    case .mention: return "Mention"
    }
  }

  var systemImage: String {
    switch self {
    case .timeline: return "house"
    case .list: return "list.dash.header.rectangle"
    case .search: return "doc.text.magnifyingglass"
    case .space: return "airplane"
    case .bookmark: return "book.closed"
    case .like: return "heart"
    case .mention: return "at"
    }
  }
}
