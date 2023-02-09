//
//  SubscriptionView.swift
//

import SwiftUI

public struct SubscriptionView: View {
  @StateObject var viewModel = SubscriptionViewModel()
  @Binding var subscriptionExpireDate: Date?
  
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
    
    VStack {
      Image(icon.iconName, bundle: .module)
        .resizable()
        .scaledToFit()
        .cornerRadius(15)
        .padding(40)
      
      Text("Thanks for using Penguin!")
        .font(.title)
        .bold()
      
      ForEach(viewModel.products) { product in
        Button {
          Task {
            let transaction = await viewModel.purchase(product: product)
            subscriptionExpireDate = transaction?.expirationDate
            Secure.subscriptionExpireDate = transaction?.expirationDate
          }
        } label: {
          ProductCell(product: product)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle)
        .padding(.horizontal, 40)
      }
      
      #if DEBUG
      Button {
        isPresentedManageSubscription.toggle()
      } label: {
        Label("Manage Subscription", systemImage: "gear")
      }
      .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.roundedRectangle)
      .padding(.horizontal, 40)
      #endif
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(icon.color.opacity(0.3))
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
