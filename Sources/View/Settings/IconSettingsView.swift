//
//  IconSettingsView.swift
//

import SwiftUI

struct Icon: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let iconName: String
}

struct IconSettingsView: View {
  @Environment(\.settings) var settings
  
  let icons: [Icon] = [
    .init(name: "Primary", iconName: "AppIcon"),
    .init(name: "Secondary", iconName: "AppIcon1"),
  ]
  
  let primaryIconName = "AppIcon"
  
  @MainActor
  var currentIcon: Icon {
    let currentIconName = UIApplication.shared.alternateIconName ?? primaryIconName
    return icons.first { $0.iconName == currentIconName }!
  }
  
  @State var selectedIcon: Icon?
  
  @MainActor
  func changeIcon(_ iconName: String) async {
    guard iconName != currentIcon.iconName else { return }
    
    let iconName: String? = iconName == primaryIconName ? nil : iconName
    
    do {
      try await UIApplication.shared.setAlternateIconName(iconName)
    } catch {
      print(error)
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
      Image(uiImage: UIImage(named: icon.iconName)!)
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
        ForEach(icons) { icon in
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
