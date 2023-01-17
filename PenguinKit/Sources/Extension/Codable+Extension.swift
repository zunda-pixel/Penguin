//
//  Codable+Extension.swift
//

import Foundation

extension JSONEncoder {
  func encodeIfExists<T>(_ value: T?) throws -> Data? where T: Encodable {
    guard let value else { return nil }

    return try self.encode(value)
  }
}

extension JSONDecoder {
  func decodeIfExists<T>(_ type: T.Type, from data: Data?) throws -> T? where T: Decodable {
    guard let data else { return nil }

    return try self.decode(T.self, from: data)
  }
}
