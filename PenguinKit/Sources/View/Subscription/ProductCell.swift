//
//  ProductCell.swift
//

import StoreKit
import SwiftUI

struct ProductCell: View {
  let product: Product

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(product.displayName)

        if let period = product.subscription?.subscriptionPeriod {
          Text("\(period.value) \(period.unit.localizedDescription)")
            .font(.callout)
        }
      }

      Spacer()

      Text("\(product.displayPrice)")
    }
  }
}
