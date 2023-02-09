//
//  SubscriptionViewModel.swift
//

import Foundation
import StoreKit

enum StoreError: Error {
  case failedVerification
}

@MainActor
final class SubscriptionViewModel: ObservableObject {
  @Published var response: SKProductsResponse?
  @Published var products: [Product] = []
  @Published var errorHandle: ErrorHandle?

  var updates: Task<Void, Never>? = nil

  init() {
    self.updates = self.newTransactionListenerTask()
  }

  deinit {
    updates?.cancel()
  }

  private func newTransactionListenerTask() -> Task<Void, Never> {
    // https://developer.apple.com/documentation/storekit/transaction/3851206-updates
    Task {
      for await verificationResult in Transaction.updates {
        switch verificationResult {
        case .verified(let transaction): await transaction.finish()
        case .unverified(_, let error):
          let errorHandle = ErrorHandle(error: error)
          errorHandle.log()
          self.errorHandle = errorHandle
        }
      }
    }
  }

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

  func fetchProducts() async {
    do {
      self.products = try await SubscribeManager.products().sorted(by: \.price)
    } catch {
      self.errorHandle = ErrorHandle(error: error)
    }
  }

  func purchase(product: Product) async -> StoreKit.Transaction? {
    do {
      let result = try await product.purchase()

      switch result {
      case .success(let verification):
        let transaction = try checkVerified(verification)
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
