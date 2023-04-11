//
//  IconSettingsView.swift
//

import SwiftUI

struct Icon: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let iconName: String

  static let icons: [Icon] = [
    .init(name: "Primary", iconName: "AppIcon"),
    .init(name: "Secondary", iconName: "AppIcon1"),
  ]
}

#if !os(macOS)
  struct IconSettingsView: View {
    @Environment(\.settings) var settings

    @State var selectedIcon: Icon
    @State var errorHandle: ErrorHandle?

    init() {
      let currentIcon = Icon.icons.first { $0.iconName == UIApplication.shared.iconName }!
      self._selectedIcon = .init(initialValue: currentIcon)
    }

    @MainActor
    func changeIcon(_ icon: Icon) async {
      guard icon.iconName != selectedIcon.iconName else { return }

      let iconName: String? = icon.iconName == Configuration(bundle: .main).primaryIconName ? nil : icon.iconName

      let previousIcon = selectedIcon

      selectedIcon = icon

      do {
        try await UIApplication.shared.setAlternateIconName(iconName)
      } catch {
        let errorHandle = ErrorHandle(error: error)
        errorHandle.log()
        self.errorHandle = errorHandle

        selectedIcon = previousIcon
      }
    }

    @MainActor
    func iconCell(icon: Icon) -> some View {
      Label {
        Text(icon.name)
        Spacer()
        if icon == selectedIcon {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(settings.colorType.colorSet.tintColor)
        } else {
          Image(systemName: "circle")
        }
      } icon: {
        Image(icon.iconName, bundle: .module)
          .resizable()
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .scaledToFit()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        Task {
          await changeIcon(icon)
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
      .environment(\.editMode, .constant(.active))
    }
  }

  struct IconSettingsView_Previews: PreviewProvider {
    static var previews: some View {
      IconSettingsView()
    }
  }
#endif
