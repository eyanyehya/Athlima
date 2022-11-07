//
//  PostsViewModel.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/19/22.
//  View model that handles loading posts from the firebase database for specific filters

import Foundation

// loadable enum that represents different possible states of the post loading process
enum Loadable<Value> {
    // when the posts are loading
    case loading
    
    // when an error occurs and the error itself
    case error(Error)
    
    // when the posts have been loaded and the value is the list of posts
    case loaded(Value)
    
    var value: Value? {
        get {
            // if the posts have loaded return the posts otherwise nil
            if case let .loaded(value) = self {
                return value
            }
            return nil
        }
        set {
            // if the new value is not nil it means that posts have loaded so set value to .loaded(posts list)
            guard let newValue = newValue else { return }
            self = .loaded(newValue)
        }
    }
}

@MainActor
class PostsViewModel: ObservableObject {
    
    // filter enum definition used to display different types of posts
    enum Filter: Equatable {
        case all, author(User), eventsAttending, eventsCreated
    }
    
    // list of posts
    @Published var posts: Loadable<[Post]> = .loading
    
    // post repository that handles creating and fetching data from firebase
    private let postsRepository: PostsRepositoryProtocol
    
    // filter indicating which types of posts we want to display
    let filter: Filter

    init(filter: Filter = .all, postsRepository: PostsRepositoryProtocol) {
        self.filter = filter
        self.postsRepository = postsRepository
    }
    
    // the title that will be used in the PostListView based on the filter
    var title: String {
        switch filter {
        case .all:
            return "Activities"
        case let .author(author):
            return "\(author.name)’s Events"
        case .eventsAttending:
            return "Events Joined"
        case .eventsCreated:
            return "My Events"
        }
    }

    // function that fetches posts given a filter
    func fetchPosts() {
        Task {
            do {
                // set posts to the loaded posts
                posts = .loaded(try await postsRepository.fetchPosts(matching: filter))
            }
            // if an error occurs print an error message and set posts to an error
            catch {
                print("[PostsViewModel] Cannot fetch posts: \(error)")
                posts = .error(error)
            }
        }
    }
    
    // function that creates a view model for the individual posts
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        // a delete action for when the user decides to delete their post
        let deleteAction = { [weak self] in
            // delete in server
            try await self?.postsRepository.delete(post)
            // delete locally
            self?.posts.value?.removeAll { $0 == post }
        }
        
        // join action that allows user to join an event
        let joinEventAction = { [weak self] in
            // add event to users events attending list
            try await self?.postsRepository.join(post)
            
            // get index of the post
            guard let i = self?.posts.value?.firstIndex(of: post) else { return }

            // reduce the number of players missing if players missing >=1
            if (self?.posts.value?[i].playersMissing)! >= 1 {
                self?.posts.value?[i].playersMissing -= 1
            }
        }

        return PostRowViewModel(
            post: post,
            deleteAction: postsRepository.canDelete(post) ? deleteAction : nil,
            joinEventAction: joinEventAction
        )
    }
    
    // function that creates a new post view model that allows the user to create a new post
    func makeNewPostViewModel() -> FormViewModel<Post> {
        return FormViewModel(
            // initial values
            initialValue: Post(title: "", description: "", time: Date.now, sport: .none, phoneNumber: "0", location: LocationInfo(name: "", countryCode: "", coordinate: Coordinate(latitude: 123, longitude: 456)), playersMissing: 0, level: .Recreational, ageRequired: .noPreference, author: postsRepository.user, usersAttending: []),
            // action that occurs when user creates a post
            action: { [weak self] post in
                try await self?.postsRepository.create(post)
            }
        )
    }
}

// function in the PostsRepositoryProtocol that fetches posts based on a filter
private extension PostsRepositoryProtocol {
    func fetchPosts(matching filter: PostsViewModel.Filter) async throws -> [Post] {
        switch filter {
        case .all:
            return try await fetchAllPosts()
        case let .author(author):
            return try await fetchPosts(by: author)
        case .eventsAttending:
            return try await fetchCurrentUserEventsAttending()
        case .eventsCreated:
            return try await fetchCurrentUsersPosts()
        }
    }
}

extension Loadable where Value: RangeReplaceableCollection {
    static var empty: Loadable<Value> { .loaded(Value()) }
}

extension Loadable: Equatable where Value: Equatable {
    static func == (lhs: Loadable<Value>, rhs: Loadable<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.error(error1), .error(error2)):
            return error1.localizedDescription == error2.localizedDescription
        case let (.loaded(value1), .loaded(value2)):
            return value1 == value2
        default:
            return false
        }
    }
}

#if DEBUG
extension Loadable {
    func simulate() async throws -> Value {
        switch self {
        case .loading:
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            fatalError("Timeout exceeded for “loading” case preview")
        case let .error(error):
            throw error
        case let .loaded(value):
            return value
        }
    }
    
    static var error: Loadable<Value> { .error(PreviewError()) }
     
    private struct PreviewError: LocalizedError {
        let errorDescription: String? = "Lorem ipsum dolor set amet."
    }
}
#endif


