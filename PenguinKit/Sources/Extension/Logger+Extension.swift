//
//  Logger+Extension.swift
//

import os

extension Logger {
  static let main: Logger = Logger(
    subsystem: InfoPlistProvider.bundleIdentifier,
    category: "main"
  )
}
