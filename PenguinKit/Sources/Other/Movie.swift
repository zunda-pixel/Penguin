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
      let fileName = receivedData.file.lastPathComponent
      let copy: URL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
      if fileManager.fileExists(atPath: copy.path()) {
        try fileManager.removeItem(at: copy)
      }
      try fileManager.copyItem(at: receivedData.file, to: copy)
      return .init(url: copy)
    }
  }
}
