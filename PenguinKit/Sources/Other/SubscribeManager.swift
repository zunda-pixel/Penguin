//
//  SubscribeManager.swift
//

import Foundation
import StoreKit

enum SubscribeManager {
  private static let subscribeProductIDs: Set<String> = [
    "com.zunda.penguin.subscriptions.monthly",
    "com.zunda.penguin.subscriptions.yearly",
  ]
  
  static func products() async throws -> [Product] {
    try await Product.products(for: subscribeProductIDs)
  }
  
  static func purchasedProducts() async -> StoreKit.VerificationResult<StoreKit.Transaction>? {
    var result: StoreKit.VerificationResult<StoreKit.Transaction>?
    
    await withTaskGroup(of: StoreKit.VerificationResult<StoreKit.Transaction>?.self) { group in
      for id in subscribeProductIDs {
        group.addTask {
          await Transaction.currentEntitlement(for: id)
        }
      }
      
      for await newResult in group {
        if let newResult {
          result = newResult
          break
        }
      }
    }
    
    return result
  }
}
