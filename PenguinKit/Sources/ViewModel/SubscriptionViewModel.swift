//
//  SubscriptionViewModel.swift
//

import Foundation
import StoreKit

enum StoreError: Error {
  case failedVerification
}

actor SubscriptionViewModel: ObservableObject {
  @MainActor @Published var response: SKProductsResponse?
  @MainActor @Published var products: [Product] = []
  @MainActor @Published var errorHandle: ErrorHandle?

  func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    //Check whether the JWS passes StoreKit verification.
    switch result {
    case .unverified:
      //StoreKit parses the JWS, but it fails verification.
      throw StoreError.failedVerification
    case .verified(let safe):
      //The result is verified. Return the unwrapped value.
      return safe
    }
  }
  
  @MainActor
  func fetchProducts() async {
    do {
      self.products = try await SubscribeManager.products().sorted(by: \.price)
    } catch {
      self.errorHandle = ErrorHandle(error: error)
    }
  }
  
  @MainActor
  func purchase(product: Product) async -> StoreKit.Transaction? {
    do {
      let result = try await product.purchase()
      
      switch result {
      case .success(let verification):
        let transaction = try await checkVerified(verification)
        return transaction
      case .pending, .userCancelled: return nil
      @unknown default:
        fatalError("Not Implemented for \(result)")
      }
    } catch {
      self.errorHandle = ErrorHandle(error: error)
    }
    
    return nil
  }
}
