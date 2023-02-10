//
//  ProductCell.swift
//

import StoreKit
import SwiftUI

struct ProductCell: View {
  @StateObject var model: ProductCellModel
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(model.product.displayName)
        
        if let period = model.product.subscription?.subscriptionPeriod {
          Text("\(period.value) \(period.unit.localizedDescription)")
            .font(.callout)
        }
      }
      
      Spacer()
      
      Button {
       Task {
          await model.purchase()
        }
      } label: {
        Group {
          if model.loading {
            ProgressView()
          } else {
            Text("\(model.product.displayPrice)")
          }
        }
        .padding(.vertical, 4)
        .frame(minWidth: 60)
      }
      .disabled(model.loading)
      .buttonStyle(.bordered)
    }
  }
}
