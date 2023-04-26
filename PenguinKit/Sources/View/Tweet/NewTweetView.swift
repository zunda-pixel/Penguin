//
//  CreateTweetView.swift
//

import PhotosUI
import Sweet
import SwiftUI

struct NewTweetView<ViewModel: NewTweetViewProtocol>: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.loginUsers) var loginUsers
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme

  @StateObject var viewModel: ViewModel

  @FocusState private var showKeyboard: Bool

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          HStack(alignment: .top) {
            let user = loginUsers.first { $0.id == viewModel.userID }!

            Menu {
              SelectUserView(currentUser: .init(get: { user }, set: { viewModel.userID = $0.id }))
            } label: {
              ProfileImageView(url: user.profileImageURL!)
                .frame(width: 40, height: 40)
            }

            VStack {
              if let reply = viewModel.reply {
                ScrollView(.horizontal) {
                  HStack {
                    ForEach(reply.replyUsers.filter { viewModel.selectedUserID.contains($0.id) }) {
                      user in
                      Label {
                        Text(user.userName)
                      } icon: {
                        ProfileImageView(url: user.profileImageURL!)
                          .frame(width: 25, height: 25)
                      }
                    }
                  }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                  viewModel.isPresentedSelectUserView.toggle()
                }
                .sheet(isPresented: $viewModel.isPresentedSelectUserView) {
                  SelectReplyUsersView(
                    tweetOwnerID: reply.ownerID,
                    allUsers: reply.replyUsers,
                    selection: $viewModel.selectedUserID
                  )
                  .presentationDetents([.medium])
                }
              }

              HStack(alignment: .top) {
                TextField(viewModel.placeHolder, text: $viewModel.text, axis: .vertical)
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
              QuotedTweetCellView(
                userID: viewModel.userID,
                tweet: quoted.tweet,
                user: quoted.author
              )
              .padding()
              .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 2))
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

            Button {
              withAnimation {
                viewModel.pollButtonAction()
              }
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
      .navigationTitle(viewModel.title)
      .navigationBarTitleDisplayModeIfAvailable(.inline)
      .toolbar {
        #if os(macOS)
          let tweetPlacement: ToolbarItemPlacement = .navigation
        #else
          let tweetPlacement: ToolbarItemPlacement = .navigationBarTrailing
        #endif

        ToolbarItem(placement: tweetPlacement) {
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

        #if os(macOS)
          let closePlacement: ToolbarItemPlacement = .navigation
        #else
          let closePlacement: ToolbarItemPlacement = .navigationBarLeading
        #endif

        ToolbarItem(placement: closePlacement) {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
  }
}

struct NewTweetView_Preview: PreviewProvider {
  struct Preview: View {
    @State var isPresented = false

    var body: some View {
      Button("Show") {
        isPresented.toggle()
      }
      .sheet(isPresented: $isPresented) {
        NewTweetView(viewModel: NewTweetViewModel(userID: "1234"))
          .environment(
            \.loginUsers,
            [
              .init(
                id: "1234", name: "name", userName: "userName",
                profileImageURL: URL(
                  string:
                    "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg"
                ))
            ])
      }
    }
  }

  static var previews: some View {
    Preview()
  }
}
