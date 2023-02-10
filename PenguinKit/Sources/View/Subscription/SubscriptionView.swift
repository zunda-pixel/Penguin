//
//  SubscriptionView.swift
//

import SwiftUI
import Sweet

public struct SubscriptionView: View {
  @StateObject var viewModel = SubscriptionViewModel()
  @Binding var subscriptionExpireDate: Date?
  @Binding var settings: Settings
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  
  @State var isPresentedSettingsView: Bool = false
  
#if DEBUG
  @State var isPresentedManageSubscription: Bool = false
#endif
  
  public init(
    currentUser: Binding<Sweet.UserModel?>,
    loginUsers: Binding<[Sweet.UserModel]>,
    settings: Binding<Settings>,
    expireDate subscriptionExpireDate: Binding<Date?>
  ) {
    self._currentUser = currentUser
    self._loginUsers = loginUsers
    self._settings = settings
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
      
      HStack {
        Button {
          Task {
            let product = await SubscribeManager.purchasedProducts()
            let subscriptionExpireDate = try? product?.payloadValue.expirationDate
            Secure.subscriptionExpireDate = subscriptionExpireDate
            self.subscriptionExpireDate = subscriptionExpireDate
          }
        } label: {
          Label("Restore", systemImage: "clock.arrow.circlepath")
            .frame(maxWidth: .infinity)
        }
        .tint(settings.colorType.colorSet.tintColor.opacity(0.3))
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle)
        
        Button {
          isPresentedSettingsView.toggle()
        } label: {
          Label("Settings", systemImage: "gear")
            .frame(maxWidth: .infinity)
        }
        .tint(settings.colorType.colorSet.tintColor.opacity(0.3))
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle)
        .sheet(isPresented: $isPresentedSettingsView) {
          SettingsView(
            settings: $settings,
            currentUser: $currentUser,
            loginUsers: $loginUsers,
            subscriptionExpireDate: $subscriptionExpireDate
          )
        }
      }
      
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
#endif
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.horizontal, 40)
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.fetchProducts()
    }
  }
}

struct ManageSubscriptionView_Preview: PreviewProvider {
  static var previews: some View {
    SubscriptionView(
      currentUser: .constant(nil),
      loginUsers: .constant([]),
      settings: .constant(.init()),
      expireDate: .constant(nil)
    )
  }
}
