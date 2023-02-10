//
//  ProductCellModel.swift
//

import Foundation
import StoreKit

@MainActor final class ProductCellModel: ObservableObject {
  let product: Product
  
  private let purchase: () async -> Void
  
  @Published var loading: Bool
  
  init(product: Product, purchase: @escaping () async -> Void) {
    self.product = product
    self.purchase = purchase
    self.loading = false
  }
  
  func purchase() async {
    guard !loading else { return }
    loading.toggle()
    defer { loading.toggle() }
    try? await Task.sleep(for: .seconds(3))
    await purchase()
  }
}
