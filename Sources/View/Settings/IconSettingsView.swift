//
//  IconSettingsView.swift
//

import SwiftUI

struct Icon: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let iconName: String
  let imageName: String
  
  static let icons: [Icon] = [
    .init(name: "Primary", iconName: "AppIcon", imageName: "AppIconImage"),
    .init(name: "Secondary", iconName: "AppIcon1", imageName: "AppIcon1Image"),
  ]
}

struct IconSettingsView: View {
  @Environment(\.settings) var settings
    
  @MainActor
  var currentIcon: Icon {
    let currentIconName = UIApplication.shared.iconName
    return Icon.icons.first { $0.iconName == currentIconName }!
  }
  
  @State var selectedIcon: Icon?
  @State var errorHandle: ErrorHandle?
  
  
  @MainActor
  func changeIcon(_ iconName: String) async {
    guard iconName != currentIcon.iconName else { return }
    
    let iconName: String? = iconName == UIApplication.primaryIconName ? nil : iconName
    
    do {
      try await UIApplication.shared.setAlternateIconName(iconName)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
  
  @MainActor
  func iconCell(icon: Icon) -> some View {
    Label {
      Text(icon.name)
      Spacer()
      if(icon == currentIcon) {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(settings.colorType.colorSet.tintColor)
      } else {
        Image(systemName: "circle")
      }
    } icon: {
      Image(icon.imageName)
        .resizable()
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .scaledToFit()
    }
    .contentShape(Rectangle())
    .onTapGesture {
      Task {
        await changeIcon(icon.iconName)
      }
    }
  }
  
  func creatorCell(userName: String, iconURL: URL, link: URL) -> some View {
    Link(destination: link) {
      Label {
        Text(userName)
      } icon: {
        AsyncImage(url: iconURL) { image in
          image
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
        } placeholder: {
          ProgressView()
        }
      }
    }
  }
  
  
  var body: some View {
    List {
      Section {
        ForEach(Icon.icons) { icon in
          iconCell(icon: icon)
        }
      }
      Section {
        creatorCell(
          userName: "@catalyststuff",
          iconURL: URL(string: "https://avatar.freepik.com/15830015.jpg")!,
          link: URL(string: "https://www.freepik.com/author/catalyststuff")!
        )
      }
    }
    .alert(errorHandle: $errorHandle)
    .onAppear {
      selectedIcon = currentIcon
    }
    .environment(\.editMode, .constant(.active))
  }
}

struct IconSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    IconSettingsView()
  }
}
