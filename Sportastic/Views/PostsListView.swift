//
//  PostsListView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  View that displays posts (in different cases for like all posts, users created posts, etc.)

import SwiftUI

struct PostsListView: View {
    // posts view model that
    @StateObject var viewModel: PostsViewModel
        
    @State private var searchText = ""

    @State private var showNewPostForm = false

    var body: some View {
        Group {
            switch viewModel.posts {
            // posts are loading
            case .loading:
                ProgressView()
            // there is an error
            case let .error(error):
                EmptyListView(
                    title: "Cannot Load Posts",
                    message: error.localizedDescription,
                    retryAction: {
                        viewModel.fetchPosts()
                    }
                )
            // there are no posts
            case .empty:
                // show a message based on the filter (i.e what tab the user is on)
                switch viewModel.filter {
                case .eventsCreated:
                    EmptyListView(
                        title: "No Events Created",
                        message: "You haven't created any events yet. Click on the top right to create an event."
                    )
                case .eventsAttending:
                    EmptyListView(
                        title: "No Events Joined",
                        message: "You haven't joined any events yet."
                    )
                case .all:
                    EmptyListView(
                        title: "No Events",
                        message: "There aren't any events to join at the moment."
                    )
                default:
                    EmptyListView(
                        title: "No Events",
                        message: "There aren't any events to join at the moment"
                    )
                }
            // if the posts loaded successfully
            case let .loaded(posts):
                ScrollView {
                    ForEach(posts) { post in
                        // if the user hasnt searched anything or a post should be shown based on their search
                        if searchText.isEmpty || post.contains(searchText) {
                            // PostRowView displaying specific info about each post
                            PostRowView(viewModel: viewModel.makePostRowViewModel(for: post), filter: viewModel.filter)
                            Divider()
                        }
                    }
                    .searchable(text: $searchText)
                    .animation(.default, value: posts)
                }
            }
        }
        .navigationTitle(viewModel.title)
        .onAppear {
            // when view appears fetch posts
            viewModel.fetchPosts()
        }
        .sheet(isPresented: $showNewPostForm) {
            // display new post form when user clicks on new post button
            NewPostFormView(viewModel: viewModel.makeNewPostViewModel())
        }
        .toolbar {
            if viewModel.filter == .all {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
        }
        
    }
}

#if DEBUG
struct PostsListView_Previews: PreviewProvider {
    static var previews: some View {
        ListPreview(state: .loaded([Post.testPost]))
        ListPreview(state: .empty)
        ListPreview(state: .error)
        ListPreview(state: .loading)
    }
    
    @MainActor
    private struct ListPreview: View {
        let state: Loadable<[Post]>
     
        var body: some View {
            let postsRepository = PostsRepositoryStub(state: state)
            let viewModel = PostsViewModel(postsRepository: postsRepository)
            NavigationView {
                PostsListView(viewModel: viewModel)
            }
        }
    }
}
#endif
