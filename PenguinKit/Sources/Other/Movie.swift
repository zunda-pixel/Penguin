//
//  Movie.swift
//

import CoreTransferable

struct Movie: Transferable {
  let url: URL

  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .movie) { movie in
      SentTransferredFile(movie.url)
    } importing: { receivedData in
      let fileManager = FileManager.default
      let fileName = "\(UUID().uuidString).\(receivedData.file.pathExtension)"
      let copy: URL = fileManager.temporaryDirectory.appending(
        path: fileName,
        directoryHint: .notDirectory
      )
      try fileManager.copyItem(at: receivedData.file, to: copy)
      return .init(url: copy)
    }
  }
}
