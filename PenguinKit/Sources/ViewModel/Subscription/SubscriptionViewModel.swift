//
//  SubscriptionViewModel.swift
//

import Foundation
import StoreKit

enum StoreError: Error {
  case failedVerification
  case failedFetchPurchase
}

@MainActor
final class SubscriptionViewModel: ObservableObject {
  @Published var response: SKProductsResponse?
  @Published var products: [Product] = []
  @Published var errorHandle: ErrorHandle?
  @Published var selectedProduct: Product?
  @Published var loading: Bool = false

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
      self.selectedProduct = self.products.first
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func purchase() async -> Date? {
    guard !loading else { return nil }
    loading.toggle()
    defer { loading.toggle() }

    guard let selectedProduct else { return nil }

    do {
      let result = try await selectedProduct.purchase()

      switch result {
      case .success(let verification):
        let transaction = try checkVerified(verification)
        let subscriptionExpireDate = transaction.expirationDate
        Secure.subscriptionExpireDate = subscriptionExpireDate
        return subscriptionExpireDate
      case .pending, .userCancelled: return nil
      @unknown default:
        fatalError("Not Implemented for \(result)")
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }

    return nil
  }
}
