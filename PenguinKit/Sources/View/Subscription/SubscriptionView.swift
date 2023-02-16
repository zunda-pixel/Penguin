//
//  SubscriptionView.swift
//

import StoreKit
import Sweet
import SwiftUI

public struct SubscriptionView: View {
  @StateObject var viewModel = SubscriptionViewModel()
  @Binding var subscriptionExpireDate: Date?
  @Binding var settings: Settings
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]

  @State var isPresentedSettingsView: Bool = false

  #if DEBUG && !os(macOS)
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

    let binding: Binding<Product?> = .init(
      get: { viewModel.selectedProduct },
      set: { newValue in
        if let newValue {
          viewModel.selectedProduct = newValue
        }
      }
    )

    List(selection: binding) {
      Image(icon.iconName, bundle: .module)
        .resizable()
        .frame(maxWidth: 100, maxHeight: 100)
        .cornerRadius(15)
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)

      Text("Subscription for Penguin")
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)

      #if os(macOS)
        let backgroundColor: Color = Color(.systemGray)
      #else
        let backgroundColor: Color = Color(.systemBackground)
      #endif

      ForEach(viewModel.products) { product in
        HStack(alignment: .top) {
          ProductCell(product: product)
          if viewModel.selectedProduct == product {
            Image(systemName: "checkmark.circle")
              .symbolRenderingMode(.palette)
              .foregroundStyle(settings.colorType.colorSet.tintColor)
          } else {
            Image(systemName: "circle")
          }
        }
        .tag(product)
        .padding(17)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 17, height: 17)))
        .if(viewModel.selectedProduct == product) {
          $0.overlay {
            RoundedRectangle(cornerSize: CGSize(width: 17, height: 17))
              .stroke(settings.colorType.colorSet.tintColor, lineWidth: 3)
          }
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(backgroundColor)
      .listRowInsets(EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3))

      Text("Plan automatically renews monthly.")
        .font(.caption)
        .foregroundColor(.secondary)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

      Button {
        Task {
          self.subscriptionExpireDate = await viewModel.purchase()
        }
      } label: {
        Text("Subscribe")
          .foregroundColor(.white)
          .padding(.vertical)
          .frame(maxWidth: .infinity, alignment: .center)
          .background(settings.colorType.colorSet.tintColor)
      }
      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
      .clipShape(RoundedRectangle(cornerRadius: 17))
      .disabled(viewModel.selectedProduct == nil || viewModel.loading)
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)

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
        }
        .buttonStyle(.bordered)
        #if os(macOS)
          .buttonBorderShape(.roundedRectangle)
        #else
          .buttonBorderShape(.capsule)
        #endif
        .listRowSeparator(.hidden)

        Spacer()

        Button {
          isPresentedSettingsView.toggle()
        } label: {
          Label("Settings", systemImage: "gear")
        }
        .buttonStyle(.bordered)
        #if os(macOS)
          .buttonBorderShape(.roundedRectangle)
        #else
          .buttonBorderShape(.capsule)
        #endif
        .listRowSeparator(.hidden)
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
            .frame(maxWidth: .infinity)
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .listRowSeparator(.hidden)
      #endif
    }
    .listStyle(.inset)
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
