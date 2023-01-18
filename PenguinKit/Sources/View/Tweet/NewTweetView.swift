//
//  CreateTweetView.swift
//

import CoreLocation
import PhotosUI
import Sweet
import SwiftUI

#if !os(macOS)
  import CoreLocationUI
#endif

struct NewTweetView<ViewModel: NewTweetViewProtocol>: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.loginUsers) var loginUsers
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme

  @ObservedObject var viewModel: ViewModel

  @FocusState private var showKeyboard: Bool

  var body: some View {
    ScrollView {
      VStack {
        HStack {
          Button("Close") {
            dismiss()
          }
          Spacer()
          Text("New Tweet")
          Spacer()
          Button("Tweet") {
            Task {
              do {
                try await viewModel.postTweet()
                dismiss()
              } catch {
                let errorHandle = ErrorHandle(error: error)
                errorHandle.log()
                viewModel.errorHandle = errorHandle
              }
            }
          }
          .disabled(viewModel.disableTweetButton)
          .buttonStyle(.bordered)
        }

        HStack(alignment: .top) {
          let user = loginUsers.first { $0.id == viewModel.userID }!

          Menu {
            SelectUserView(currentUser: .init(get: { user }, set: { viewModel.userID = $0.id }))
          } label: {
            ProfileImageView(url: user.profileImageURL!)
              .frame(width: 40, height: 40)
          }

          VStack {
            HStack(alignment: .top) {
              TextField(viewModel.title, text: $viewModel.text, axis: .vertical)
                .focused($showKeyboard, equals: true)

              Text("\(viewModel.leftTweetCount)")
            }

            if let poll = viewModel.poll, poll.options.count > 1 {
              NewPollView(
                options: .init(
                  get: { viewModel.poll!.options },
                  set: { viewModel.poll?.options = $0 }
                ),
                duration: .init(
                  get: { TimeInterval(poll.durationMinutes * 60) },
                  set: { viewModel.poll?.durationMinutes = Int($0 / 60) }
                )
              )
              .padding()
              .overlay(
                RoundedRectangle(cornerRadius: 20)
                  .stroke(.secondary, lineWidth: 2)
              )
              .padding(.horizontal, 2)
            }
          }
        }

        if !viewModel.photos.isEmpty {
          Text("Photo Upload UnAvailable")
        }

        LazyVGrid(columns: .init(repeating: .init(), count: 2)) {
          ForEach(viewModel.photos) { photo in
            PhotoView(photo: photo)
              .frame(width: 100, height: 100)
              .scaledToFit()
          }
        }

        VStack(alignment: .leading) {
          if let quoted = viewModel.quoted {
            QuotedTweetCellView(userID: viewModel.userID, tweet: quoted.tweet, user: quoted.author)
              .padding()
              .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 2))
          }
        }

        if let location = viewModel.locationString {
          Text("Location Upload UnAvailable")

          HStack {
            Text(location)
              .foregroundColor(.secondary)

            Button {
              self.viewModel.locationString = nil
            } label: {
              Image(systemName: "multiply.circle")
            }
          }
        }

        Picker("ReplySetting", selection: $viewModel.selectedReplySetting) {
          ForEach(Sweet.ReplySetting.allCases, id: \.rawValue) { replySetting in
            Text(replySetting.description)
              .tag(replySetting)
          }
        }

        HStack {
          PhotosPicker(
            selection: $viewModel.photosPickerItems,
            maxSelectionCount: 4,
            selectionBehavior: .ordered,
            preferredItemEncoding: .current,
            photoLibrary: .shared()
          ) {
            Image(systemName: "photo")
          }

          #if !os(macOS)
            LocationButton(.sendCurrentLocation) {
              Task {
                await viewModel.setLocation()
              }
            }
            .labelStyle(.iconOnly)
            .foregroundColor(settings.colorType.colorSet.tintColor)
            .tint(
              colorScheme == .dark
                ? settings.colorType.colorSet.darkPrimaryColor
                : settings.colorType.colorSet.lightPrimaryColor
            )
            .disabled(viewModel.loadingLocation)
          #endif

          Button {
            viewModel.pollButtonAction()
          } label: {
            Image(systemName: "chart.bar.xaxis")
              .rotationEffect(.degrees(90))
          }
          .disabled(viewModel.photos.count != 0)
        }
        .onChange(
          of: viewModel.photosPickerItems,
          perform: { newResults in
            Task {
              await viewModel.loadPhotos(with: newResults)
            }
          }
        )
        .alert(errorHandle: $viewModel.errorHandle)
      }
      .scrollContentAttribute()
      .onAppear {
        showKeyboard = true
      }
      .padding()
      .alert(errorHandle: $viewModel.errorHandle)
    }
    .scrollViewAttitude()
  }
}
