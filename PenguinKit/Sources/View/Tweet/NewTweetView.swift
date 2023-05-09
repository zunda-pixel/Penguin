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

  @AppStorage("firstPostTweet") var firstPostTweet = true

  @State var showWarningAlert = false

  @StateObject var viewModel: ViewModel

  @FocusState private var showKeyboard: Bool

  func postTweet() async {
    if firstPostTweet {
      showWarningAlert.toggle()
    } else {
      await viewModel.postTweet()
      dismiss()
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          HStack(alignment: .top) {
            userProfile

            VStack {
              if let reply = viewModel.reply {
                replyView(reply: reply)
              }

              TextField(
                viewModel.placeHolder,
                text: $viewModel.text,
                axis: .vertical
              )
              .focused($showKeyboard, equals: true)

              if let poll = viewModel.poll, poll.options.count > 1 {
                pollView(poll: poll)
              }
            }
          }

          if !viewModel.photos.isEmpty {
            Text("Photo Upload UnAvailable")

            mediasView
          }

          if let quoted = viewModel.quoted {
            quotedView(quoted: quoted)
          }
        }
        .scrollContentAttribute()
        .padding()
      }
      .safeAreaInset(edge: .bottom) {
        VStack(alignment: .leading, spacing: 0) {
          Divider()

          Picker("Reply Setting", selection: $viewModel.selectedReplySetting) {
            ForEach(Sweet.ReplySetting.allCases, id: \.rawValue) { replySetting in
              Label(replySetting.description, systemImage: replySetting.imageName)
                .tag(replySetting)
            }
          }
          .pickerStyle(.menu)

          Divider()

          HStack {
            photosPicker

            pollButton

            atButton

            hashButton

            Spacer()

            Text("\(viewModel.leftTweetCount)")
          }
          .padding(.vertical, 7)
          .padding(.horizontal, 13)
        }
        .frame(maxWidth: .infinity)
        .background {
          if colorScheme == .dark {
            settings.colorType.colorSet.darkPrimaryColor
          } else {
            settings.colorType.colorSet.lightPrimaryColor
          }
        }
        
      }
      .alert(errorHandle: $viewModel.errorHandle)
      .onAppear {
        showKeyboard = true
      }
      .alert(
        "This Tweet is posted to twitter.com",
        isPresented: $showWarningAlert
      ) {
        Button("Post") {
          Task {
            firstPostTweet = false
            await postTweet()
          }
        }
        Button("Cancel", role: .cancel) {}
      }
      .navigationTitle(viewModel.title)
      .navigationBarTitleDisplayModeIfAvailable(.inline)
      .toolbar {
        toolBarContent
      }
    }
  }

  var atButton: some View {
    Button {
      viewModel.text.append("@")
    } label: {
      Label("Add @", systemImage: "at")
        .labelStyle(.iconOnly)
    }
  }

  var hashButton: some View {
    Button {
      viewModel.text.append("#")
    } label: {
      Label("Add #", systemImage: "number")
        .labelStyle(.iconOnly)
    }
  }

  @ViewBuilder
  var mediasView: some View {
    let count = viewModel.photos.count < 3 ? viewModel.photos.count : 2

    GeometryReader { proxy in
      let width = proxy.size.width / CGFloat(count)
      LazyVGrid(columns: .init(repeating: .init(), count: count)) {
        ForEach(viewModel.photos) { photo in
          PhotoView(photo: photo)
            .scaledToFill()
            .frame(width: width, height: width)
            .clipped()
        }
      }
    }
  }

  @ViewBuilder
  var userProfile: some View {
    let user = loginUsers.first { $0.id == viewModel.userID }!

    Menu {
      SelectUserView(currentUser: .init(get: { user }, set: { viewModel.userID = $0.id }))
    } label: {
      ProfileImageView(url: user.profileImageURL!)
        .frame(width: 40, height: 40)
    }
  }

  @ToolbarContentBuilder
  var toolBarContent: some ToolbarContent {
    #if os(macOS)
      let tweetPlacement: ToolbarItemPlacement = .navigation
    #else
      let tweetPlacement: ToolbarItemPlacement = .navigationBarTrailing
    #endif

    ToolbarItem(placement: tweetPlacement) {
      Button("Tweet") {
        Task {
          await postTweet()
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

  var photosPicker: some View {
    PhotosPicker(
      selection: $viewModel.photosPickerItems,
      maxSelectionCount: 4,
      selectionBehavior: .ordered,
      preferredItemEncoding: .current,
      photoLibrary: .shared()
    ) {
      Image(systemName: "photo")
    }
    .disabled(viewModel.poll != nil)
    .onChange(of: viewModel.photosPickerItems) { newResults in
      Task {
        await viewModel.loadPhotos(with: newResults)
      }
    }
  }

  func quotedView(quoted: TweetContentModel) -> some View {
    QuotedTweetCellView(
      userID: viewModel.userID,
      tweet: quoted.tweet,
      user: quoted.author
    )
    .padding()
    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 2))
    // TODO foregroundColorは必要ないはず
    .foregroundColor(.primary)
  }

  var pollButton: some View {
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

  @ViewBuilder
  func replyView(reply: Reply) -> some View {
    HStack(alignment: .top) {
      ProfileImageView(url: reply.tweetContent.author.profileImageURL!)
        .frame(width: 30, height: 30)

      LinkableText(
        tweet: reply.tweetContent.tweet,
        userID: viewModel.userID,
        excludeURLs: []
      )
      .lineLimit(3)
    }
    .frame(maxWidth: 400, alignment: .leading)
    .padding(5)
    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 2))

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
        tweetOwnerID: reply.tweetContent.author.id,
        allUsers: reply.replyUsers,
        selection: $viewModel.selectedUserID
      )
      .presentationDetents([.medium])
    }
  }

  func pollView(poll: Sweet.PostPollModel) -> some View {
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
