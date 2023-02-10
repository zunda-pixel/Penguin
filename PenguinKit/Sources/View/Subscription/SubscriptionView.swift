//
//  SubscriptionView.swift
//

import SwiftUI

public struct SubscriptionView: View {
  @StateObject var viewModel = SubscriptionViewModel()
  @Binding var subscriptionExpireDate: Date?
  @Environment(\.settings) var settings
  
  #if DEBUG
    @State var isPresentedManageSubscription: Bool = false
  #endif

  public init(expireDate subscriptionExpireDate: Binding<Date?>) {
    self._subscriptionExpireDate = subscriptionExpireDate
  }

  public var body: some View {
    #if os(macOS)
      let iconName = NSApplication.shared.iconName
    #else
      let iconName = UIApplication.shared.iconName
    #endif

    let icon = Icon.icons.first { $0.iconName == iconName }!

    let padding: CGFloat = 40
    
    VStack {
      Image(icon.iconName, bundle: .module)
        .resizable()
        .scaledToFit()
        .cornerRadius(15)
        .padding(padding)

      Text("Thanks for using Penguin!")
        .font(.title)
        .bold()

      ForEach(viewModel.products) { product in
        let model: ProductCellModel = ProductCellModel(product: product) {
          let transaction = await viewModel.purchase(product: product)
          subscriptionExpireDate = transaction?.expirationDate
          Secure.subscriptionExpireDate = transaction?.expirationDate
        }
        
        ProductCell(model: model)
          .padding()
          .background(settings.colorType.colorSet.tintColor.opacity(0.3))
          .clipShape(RoundedRectangle(cornerRadius: 17))
      }
      .padding(.horizontal, padding)
      
      Button {
        Task {
          let product = await SubscribeManager.purchasedProducts()
          let subscriptionExpireDate = try? product?.payloadValue.expirationDate
          Secure.subscriptionExpireDate = subscriptionExpireDate
          self.subscriptionExpireDate = subscriptionExpireDate
        }
      } label: {
        Label("Restore", systemImage: "clock.arrow.circlepath")
      }
      .tint(settings.colorType.colorSet.tintColor.opacity(0.3))
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.roundedRectangle)
      .padding(.horizontal, padding)

      #if DEBUG && !os(macOS)
        Button {
          isPresentedManageSubscription.toggle()
        } label: {
          Label("Manage Subscription", systemImage: "gear")
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .tint(settings.colorType.colorSet.tintColor.opacity(0.3))
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle)
        .padding(.horizontal, padding)
      #endif
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.fetchProducts()
    }
  }
}

struct ManageSubscriptionView_Preview: PreviewProvider {
  static var previews: some View {
    SubscriptionView(expireDate: .constant(.now))
  }
}
