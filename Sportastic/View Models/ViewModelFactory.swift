//
//  ViewModelFactory.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  View model factory that creates view models for different views with specific requirments

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ViewModelFactory: ObservableObject {
    // current active user
    var user: User
    private let authService: AuthService
 
    init(user: User, authService: AuthService) {
        self.user = user
        self.authService = authService
    }
 
    // function that creates a posts view model with a specific filter based on what events the view will display
    // using filters reduces the amount of duplicate code drastically
    func makePostsViewModel(filter: PostsViewModel.Filter = .all) -> PostsViewModel {
        return PostsViewModel(filter: filter, postsRepository: PostsRepository(user: user))
    }

    // function that creates a profile view model that allows the user to change their profile picture, sign out, etc.
    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(user: user, authService: authService)
    }
}

#if DEBUG
extension ViewModelFactory {
    static let preview = ViewModelFactory(user: User.testUser, authService: AuthService())
}
#endif
