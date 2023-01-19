//
//  NodeView.swift
//

import SwiftUI

struct NodeView<ContentData, RowContent>: View
where
  ContentData: RandomAccessCollection,
  ContentData.Element: Identifiable,
  ContentData.Element: Equatable,
  RowContent: View
{
  var contentData: ContentData
  var children: KeyPath<ContentData.Element, ContentData>
  var rawContent: (ContentData.Element) -> RowContent

  init(
    _ contentData: ContentData,
    children: KeyPath<ContentData.Element, ContentData>,
    @ViewBuilder rawContent: @escaping (ContentData.Element) -> RowContent
  ) {
    self.contentData = contentData
    self.children = children
    self.rawContent = rawContent
  }

  var body: some View {
    ForEach(contentData) { item in
      rawContent(item)

      NodeView(
        item[keyPath: children],
        children: children
      ) { item in
        rawContent(item)
      }
    }
  }
}
